# environments/staging.tfvars
# Staging environment configuration for EKS

environment = "staging"
project_name = "devops-studio"
region = "us-west-2"

# EKS Configuration
cluster_name = "devops-studio-staging-eks"
cluster_version = "1.28"
cluster_endpoint_public_access = true
cluster_endpoint_private_access = true

# Node Group - Production-like sizing
node_instance_type = "t3.large"
node_min_size = 2
node_max_size = 5
node_desired_size = 3
node_disk_size = 50

# Networking
vpc_id = ""
vpc_cidr = "10.2.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

# Add-ons
enable_cluster_autoscaler = true
enable_aws_load_balancer_controller = true

tags = {
  Project = "DevOps Studio"
  Environment = "Staging"
  ManagedBy = "Terraform"
  Purpose = "Pre-production Testing"
}

