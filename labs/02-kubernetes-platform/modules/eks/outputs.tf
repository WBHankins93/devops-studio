# modules/eks/outputs.tf
# Output values from the EKS module

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "node_group_id" {
  description = "ID of the EKS node group"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "node_security_group_id" {
  description = "Security group ID attached to the node group"
  value       = aws_security_group.node_group.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = local.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = local.create_vpc ? aws_subnet.private[*].id : local.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = local.create_vpc ? aws_subnet.public[*].id : []
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = length(aws_iam_openid_connect_provider.cluster) > 0 ? aws_iam_openid_connect_provider.cluster[0].arn : null
}

