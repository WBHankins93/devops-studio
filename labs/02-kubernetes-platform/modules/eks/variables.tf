# modules/eks/variables.tf
# Input variables for the EKS module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
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

variable "node_instance_type" {
  description = "EC2 instance type for EKS node groups"
  type        = string
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
}

variable "node_disk_size" {
  description = "Disk size in GB for node group instances"
  type        = number
}

variable "vpc_id" {
  description = "VPC ID to use for EKS cluster. If empty, a new VPC will be created."
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (only used if vpc_id is empty)"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

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

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

