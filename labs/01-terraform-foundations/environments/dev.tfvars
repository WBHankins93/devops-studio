# environments/dev.tfvars
# Development environment configuration

environment = "dev"
project_name = "devops-studio"
region = "us-west-2"

# Networking
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

# Application - Small for development
instance_type = "t3.micro"
min_size = 1
max_size = 2
desired_capacity = 1

# Database - Minimal for development
db_instance_class = "db.t3.micro"
db_allocated_storage = 20
db_engine_version = "8.0"

# Security - Less restrictive for development
enable_deletion_protection = false

tags = {
  Project = "DevOps Studio"
  Environment = "Development"
  ManagedBy = "Terraform"
  Purpose = "Learning"
}