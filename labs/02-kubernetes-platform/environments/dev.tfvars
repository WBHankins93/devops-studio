# environments/dev.tfvars
# Development environment configuration for EKS

environment = "dev"
project_name = "devops-studio"
region = "us-west-2"

# EKS Configuration
cluster_name = "devops-studio-dev-eks"
cluster_version = "1.28"
cluster_endpoint_public_access = true
cluster_endpoint_private_access = true

# Node Group - Smaller for development
node_instance_type = "t3.medium"
node_min_size = 1
node_max_size = 3
node_desired_size = 2
node_disk_size = 20

# Networking - Create new VPC (or set vpc_id to use existing from Lab 01)
vpc_id = ""
vpc_cidr = "10.1.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

# Add-ons
enable_cluster_autoscaler = false
enable_aws_load_balancer_controller = true

tags = {
  Project = "DevOps Studio"
  Environment = "Development"
  ManagedBy = "Terraform"
  Purpose = "Learning"
}

