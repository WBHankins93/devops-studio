# modules/vpc/outputs.tf
# Output values from the VPC module

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Subnet outputs
output "public_subnets" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnets" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_cidrs" {
  description = "List of CIDR blocks of the database subnets"
  value       = aws_subnet.database[*].cidr_block
}

# Route table outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "database_route_table_id" {
  description = "ID of the database route table"
  value       = aws_route_table.database.id
}

# NAT Gateway outputs
output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs of the NAT Gateways"
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
}

# Flow logs outputs
output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.vpc[0].id : null
}

output "vpc_flow_log_cloudwatch_log_group" {
  description = "CloudWatch Log Group name for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}

# Network ACL outputs
output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = var.enable_network_acls ? aws_network_acl.public[0].id : null
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = var.enable_network_acls ? aws_network_acl.private[0].id : null
}

output "database_network_acl_id" {
  description = "ID of the database network ACL"
  value       = var.enable_network_acls ? aws_network_acl.database[0].id : null
}

# VPC Endpoint outputs
output "vpc_endpoint_s3_id" {
  description = "ID of the S3 VPC endpoint"
  value       = var.enable_vpc_endpoints && contains(var.vpc_endpoints, "s3") ? aws_vpc_endpoint.s3[0].id : null
}

output "vpc_endpoint_dynamodb_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = var.enable_vpc_endpoints && contains(var.vpc_endpoints, "dynamodb") ? aws_vpc_endpoint.dynamodb[0].id : null
}

# Availability zone mapping
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

output "subnet_mapping" {
  description = "Mapping of subnet types to their IDs by availability zone"
  value = {
    for i, az in var.availability_zones : az => {
      public   = aws_subnet.public[i].id
      private  = aws_subnet.private[i].id
      database = aws_subnet.database[i].id
    }
  }
}

# Summary information for other modules
output "vpc_config" {
  description = "VPC configuration summary for use by other modules"
  value = {
    vpc_id                    = aws_vpc.main.id
    vpc_cidr                  = aws_vpc.main.cidr_block
    public_subnets           = aws_subnet.public[*].id
    private_subnets          = aws_subnet.private[*].id
    database_subnets         = aws_subnet.database[*].id
    availability_zones       = var.availability_zones
    internet_gateway_id      = aws_internet_gateway.main.id
    nat_gateway_ids         = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
    public_route_table_id   = aws_route_table.public.id
    private_route_table_ids = aws_route_table.private[*].id
  }
}