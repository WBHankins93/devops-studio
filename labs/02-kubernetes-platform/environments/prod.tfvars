# environments/prod.tfvars
# Production environment configuration for EKS

environment = "prod"
project_name = "devops-studio"
region = "us-west-2"

# EKS Configuration
cluster_name = "devops-studio-prod-eks"
cluster_version = "1.28"
cluster_endpoint_public_access = false  # Private only for production
cluster_endpoint_private_access = true

# Node Group - Production sizing
node_instance_type = "t3.large"
node_min_size = 3
node_max_size = 10
node_desired_size = 5
node_disk_size = 100

# Networking
vpc_id = ""
vpc_cidr = "10.3.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Add-ons
enable_cluster_autoscaler = true
enable_aws_load_balancer_controller = true

tags = {
  Project = "DevOps Studio"
  Environment = "Production"
  ManagedBy = "Terraform"
  Purpose = "Production Workload"
  Backup = "Required"
  Monitoring = "Critical"
}

