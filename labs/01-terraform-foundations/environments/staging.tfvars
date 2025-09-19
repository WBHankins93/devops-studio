# environments/staging.tfvars
# Staging environment configuration

environment = "staging"
project_name = "devops-studio"
region = "us-west-2"

# Networking
vpc_cidr = "10.1.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b"]

# Application - Production-like sizing
instance_type = "t3.small"
min_size = 2
max_size = 4
desired_capacity = 2

# Database - Production-like with backups
db_instance_class = "db.t3.small"
db_allocated_storage = 50
db_engine_version = "8.0"

# Security - Production-like
enable_deletion_protection = true

tags = {
  Project = "DevOps Studio"
  Environment = "Staging"
  ManagedBy = "Terraform"
  Purpose = "Pre-production Testing"
}