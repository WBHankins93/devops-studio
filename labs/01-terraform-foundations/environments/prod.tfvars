# environments/prod.tfvars
# Production environment configuration

environment = "prod"
project_name = "devops-studio"
region = "us-west-2"

# Networking - Different CIDR to avoid conflicts
vpc_cidr = "10.2.0.0/16"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Application - Production sizing
instance_type = "t3.medium"
min_size = 3
max_size = 10
desired_capacity = 3

# Database - Production specifications
db_instance_class = "db.t3.medium"
db_allocated_storage = 100
db_engine_version = "8.0"

# Security - Maximum protection
enable_deletion_protection = true

tags = {
  Project = "DevOps Studio"
  Environment = "Production"
  ManagedBy = "Terraform"
  Purpose = "Production Workload"
  Backup = "Required"
  Monitoring = "Critical"
}