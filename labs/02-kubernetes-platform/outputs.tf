# outputs.tf
# Output values from the EKS cluster infrastructure

# Cluster Information
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

# kubectl Configuration
output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

# Node Group Information
output "node_group_id" {
  description = "ID of the EKS node group"
  value       = module.eks.node_group_id
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = module.eks.node_group_arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = module.eks.node_group_status
}

# VPC Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.eks.vpc_id
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to the node group"
  value       = module.eks.node_security_group_id
}

# Summary Output
output "infrastructure_summary" {
  description = "Summary of deployed EKS infrastructure"
  value = {
    project_name        = var.project_name
    environment         = var.environment
    region              = var.region
    cluster_name        = module.eks.cluster_name
    cluster_version     = module.eks.cluster_version
    cluster_endpoint     = module.eks.cluster_endpoint
    node_group_id       = module.eks.node_group_id
    node_desired_size   = var.node_desired_size
    vpc_id              = module.eks.vpc_id
    kubeconfig_command  = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
  }
  sensitive = true
}

