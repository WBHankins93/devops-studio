# outputs.tf
# Output values from the main infrastructure

# Project Information
output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.region
}

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "database_subnets" {
  description = "List of database subnet IDs"
  value       = module.vpc.database_subnets
}

# Application Outputs
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.web_app.load_balancer_dns_name
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = module.web_app.load_balancer_arn
}

output "application_url" {
  description = "URL of the web application"
  value       = module.web_app.application_url
}

output "health_check_url" {
  description = "Health check URL"
  value       = module.web_app.health_check_url
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.web_app.autoscaling_group_name
}

# Database Outputs
output "db_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_endpoint
  sensitive   = true
}

output "db_port" {
  description = "Database port"
  value       = module.database.db_port
}

# Security Outputs
output "web_app_security_group_id" {
  description = "Security group ID for web application"
  value       = module.web_app.security_group_id
}

output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer"
  value       = module.web_app.alb_security_group_id
}

# Monitoring Outputs
output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = module.web_app.cloudwatch_log_group_name
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.web_app.dashboard_url
}

# Summary Output for Easy Reference
output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    project_name        = var.project_name
    environment         = var.environment
    region              = var.region
    vpc_id              = module.vpc.vpc_id
    application_url     = module.web_app.application_url
    health_check_url    = module.web_app.health_check_url
    autoscaling_group   = module.web_app.autoscaling_group_name
    instance_count      = var.desired_capacity
    database_endpoint   = module.database.db_endpoint
  }
  sensitive = true
}