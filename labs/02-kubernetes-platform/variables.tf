# variables.tf
# Input variables for the EKS cluster infrastructure

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-studio"
  
  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "Project name must be between 1 and 32 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

# EKS Configuration
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
  
  validation {
    condition     = var.cluster_name == "" || (length(var.cluster_name) >= 1 && length(var.cluster_name) <= 100)
    error_message = "Cluster name must be between 1 and 100 characters if provided."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
  
  validation {
    condition     = can(regex("^1\\.(2[0-9]|3[0-9])$", var.cluster_version))
    error_message = "Cluster version must be a valid Kubernetes version (1.20-1.39)."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to EKS API server"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to EKS API server"
  type        = bool
  default     = true
}

# Node Group Configuration
variable "node_instance_type" {
  description = "EC2 instance type for EKS node groups"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
  
  validation {
    condition     = var.node_min_size >= 0 && var.node_min_size <= 10
    error_message = "Node min size must be between 0 and 10."
  }
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 10
  
  validation {
    condition     = var.node_max_size >= var.node_min_size && var.node_max_size <= 20
    error_message = "Node max size must be >= min_size and <= 20."
  }
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
  
  validation {
    condition     = var.node_desired_size >= var.node_min_size && var.node_desired_size <= var.node_max_size
    error_message = "Node desired size must be between min_size and max_size."
  }
}

variable "node_disk_size" {
  description = "Disk size in GB for node group instances"
  type        = number
  default     = 20
  
  validation {
    condition     = var.node_disk_size >= 20 && var.node_disk_size <= 1000
    error_message = "Node disk size must be between 20 and 1000 GB."
  }
}

# Networking
variable "vpc_id" {
  description = "VPC ID to use for EKS cluster. If empty, a new VPC will be created."
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (only used if vpc_id is empty)"
  type        = string
  default     = "10.1.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
  
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for high availability."
  }
}

# Add-ons
variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler add-on"
  type        = bool
  default     = false
}

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = true
}

# Tagging
variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default = {
    Project   = "DevOps Studio"
    ManagedBy = "Terraform"
  }
  
  validation {
    condition = alltrue([
      for tag_key, tag_value in var.tags : 
      length(tag_key) <= 128 && length(tag_value) <= 256
    ])
    error_message = "Tag keys must be <= 128 characters and values <= 256 characters."
  }
}

