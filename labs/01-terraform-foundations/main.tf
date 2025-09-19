# main.tf
# Core infrastructure configuration

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module - Custom networking setup
module "vpc" {
  source = "./modules/vpc"
  
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  
  tags = var.tags
}

# Web Application Module - Auto-scaling group with ALB
module "web_app" {
  source = "./modules/web-app"
  
  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  
  ami_id           = data.aws_ami.amazon_linux.id
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  
  tags = var.tags
}

# Database Module - RDS with encryption
module "database" {
  source = "./modules/database"
  
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  database_subnets = module.vpc.database_subnets
  
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  app_security_group  = module.web_app.security_group_id
  
  tags = var.tags
}