# variables.tf
# Variable definitions for Platform Engineering Lab

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-studio"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster (from Lab 02)"
  type        = string
  default     = ""
}

