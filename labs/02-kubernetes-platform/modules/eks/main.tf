# modules/eks/main.tf
# Production-ready EKS cluster module

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Use provided VPC or create new one
  create_vpc = var.vpc_id == ""
  
  # Calculate subnet CIDRs if creating VPC
  vpc_cidr_bits = split("/", var.vpc_cidr)[1]
  subnet_bits   = 8 - (32 - local.vpc_cidr_bits)
  
  public_subnets = local.create_vpc ? [
    for i, az in var.availability_zones : 
    cidrsubnet(var.vpc_cidr, local.subnet_bits, i)
  ] : []
  
  private_subnets = local.create_vpc ? [
    for i, az in var.availability_zones : 
    cidrsubnet(var.vpc_cidr, local.subnet_bits, i + length(var.availability_zones))
  ] : []
}

# Data sources
data "aws_region" "current" {}

# VPC (if not provided)
data "aws_vpc" "existing" {
  count = local.create_vpc ? 0 : 1
  id    = var.vpc_id
}

resource "aws_vpc" "main" {
  count = local.create_vpc ? 1 : 0
  
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-vpc"
    Type = "vpc"
  })
}

resource "aws_internet_gateway" "main" {
  count = local.create_vpc ? 1 : 0
  
  vpc_id = aws_vpc.main[0].id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-igw"
    Type = "internet-gateway"
  })
}

# Public Subnets (for load balancers)
resource "aws_subnet" "public" {
  count = local.create_vpc ? length(var.availability_zones) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = local.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-public-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "public-subnet"
    "kubernetes.io/role/elb" = "1"
  })
}

# Private Subnets (for EKS nodes)
resource "aws_subnet" "private" {
  count = local.create_vpc ? length(var.availability_zones) : 0

  vpc_id            = aws_vpc.main[0].id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "private-subnet"
    "kubernetes.io/role/internal-elb" = "1"
  })
}

# NAT Gateway (for private subnet internet access)
resource "aws_eip" "nat" {
  count = local.create_vpc ? length(var.availability_zones) : 0

  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eip-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "elastic-ip"
  })
}

resource "aws_nat_gateway" "main" {
  count = local.create_vpc ? length(var.availability_zones) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-natgw-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "nat-gateway"
  })

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  count = local.create_vpc ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-rt-public"
    Type = "route-table"
  })
}

resource "aws_route_table" "private" {
  count = local.create_vpc ? length(var.availability_zones) : 0

  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-rt-private-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "route-table"
  })
}

resource "aws_route_table_association" "public" {
  count = local.create_vpc ? length(var.availability_zones) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = local.create_vpc ? length(var.availability_zones) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Get existing subnets if VPC is provided
# Try to find private subnets in existing VPC
data "aws_subnets" "existing_private" {
  count = local.create_vpc ? 0 : 1
  
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  # Look for subnets tagged as private or in private AZs
  filter {
    name   = "tag:Type"
    values = ["private-subnet", "application"]
  }
}

# If no tagged subnets found, get all subnets in VPC (user will need to filter)
data "aws_subnets" "all_existing" {
  count = local.create_vpc ? 0 : (length(data.aws_subnets.existing_private) > 0 && length(data.aws_subnets.existing_private[0].ids) == 0 ? 1 : 0)
  
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Get VPC and subnet IDs
locals {
  vpc_id = local.create_vpc ? aws_vpc.main[0].id : var.vpc_id
  
  # Get existing subnets if VPC is provided, otherwise use created ones
  # If using existing VPC, prefer tagged private subnets, otherwise use all subnets
  private_subnet_ids = local.create_vpc ? aws_subnet.private[*].id : (
    length(data.aws_subnets.existing_private) > 0 && length(data.aws_subnets.existing_private[0].ids) > 0 ? data.aws_subnets.existing_private[0].ids : (
      length(data.aws_subnets.all_existing) > 0 ? slice(data.aws_subnets.all_existing[0].ids, 0, min(length(var.availability_zones), length(data.aws_subnets.all_existing[0].ids))) : []
    )
  )
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "cluster" {
  name = "${local.name_prefix}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# IAM Role for Node Group
resource "aws_iam_role" "node_group" {
  name = "${local.name_prefix}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_group_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "node_group_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

# Security Group for EKS Cluster
resource "aws_security_group" "cluster" {
  name_prefix = "${local.name_prefix}-eks-cluster-"
  description = "Security group for EKS cluster"
  vpc_id      = local.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eks-cluster-sg"
    Type = "security-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Node Group
resource "aws_security_group" "node_group" {
  name_prefix = "${local.name_prefix}-eks-node-"
  description = "Security group for EKS node group"
  vpc_id      = local.vpc_id

  ingress {
    description     = "Allow nodes to communicate with each other"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  ingress {
    description     = "Allow pods to communicate with cluster API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eks-node-sg"
    Type = "security-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = length(local.private_subnet_ids) > 0 ? local.private_subnet_ids : (local.create_vpc ? aws_subnet.private[*].id : [])
    security_group_ids     = [aws_security_group.cluster.id]
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_cloudwatch_log_group.cluster
  ]

  tags = merge(var.tags, {
    Name = var.cluster_name
    Type = "eks-cluster"
  })
}

# CloudWatch Log Group for EKS
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-eks-logs"
    Type = "cloudwatch-log-group"
  })
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = length(local.private_subnet_ids) > 0 ? local.private_subnet_ids : (local.create_vpc ? aws_subnet.private[*].id : [])

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]
  disk_size      = var.node_disk_size

  remote_access {
    ec2_ssh_key               = null # Can be configured if needed
    source_security_group_ids = []
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_group_worker_node_policy,
    aws_iam_role_policy_attachment.node_group_cni_policy,
    aws_iam_role_policy_attachment.node_group_container_registry_policy
  ]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-node-group"
    Type = "eks-node-group"
  })
}

# EKS Add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
  
  tags = var.tags
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
  
  tags = var.tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"
  
  tags = var.tags
}

# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi" {
  count = length(aws_iam_openid_connect_provider.cluster) > 0 ? 1 : 0
  
  name = "${local.name_prefix}-eks-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.cluster[0].arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.cluster[0].url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(aws_iam_openid_connect_provider.cluster[0].url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count = length(aws_iam_role.ebs_csi) > 0 ? 1 : 0
  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi[0].name
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"
  
  service_account_role_arn = length(aws_iam_role.ebs_csi) > 0 ? aws_iam_role.ebs_csi[0].arn : null
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}

# OIDC Provider for IRSA
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  count = length(aws_eks_cluster.main.identity[0].oidc) > 0 ? 1 : 0
  
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = length(data.tls_certificate.cluster.certificates) > 0 ? [data.tls_certificate.cluster.certificates[0].sha1_fingerprint] : []
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = var.tags
}

