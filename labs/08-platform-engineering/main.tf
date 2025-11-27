# main.tf
# Platform Engineering Lab - Main Infrastructure Configuration

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = merge(
      var.tags,
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "Terraform"
        Lab         = "08-platform-engineering"
      }
    )
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# S3 bucket for Terraform state (platform-managed resources)
resource "aws_s3_bucket" "platform_state" {
  bucket = "${var.project_name}-${var.environment}-platform-state-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "platform_state" {
  bucket = aws_s3_bucket.platform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "platform_state" {
  bucket = aws_s3_bucket.platform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "platform_state_lock" {
  name           = "${var.project_name}-${var.environment}-platform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-platform-state-lock"
  }
}

# IAM role for platform automation
resource "aws_iam_role" "platform_automation" {
  name = "${var.project_name}-${var.environment}-platform-automation-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for platform automation
resource "aws_iam_role_policy" "platform_automation" {
  name = "${var.project_name}-${var.environment}-platform-automation-policy"
  role = aws_iam_role.platform_automation.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "rds:*",
          "lambda:*",
          "apigateway:*",
          "dynamodb:*",
          "s3:*",
          "eks:*",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:CreatePolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.platform_state.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.platform_state_lock.arn
      }
    ]
  })
}

# CloudWatch Log Group for platform operations
resource "aws_cloudwatch_log_group" "platform_operations" {
  name              = "/platform/${var.project_name}-${var.environment}-operations"
  retention_in_days = var.log_retention_days
}

# SSM Parameter Store for platform configuration
resource "aws_ssm_parameter" "platform_config" {
  name  = "/platform/${var.project_name}/${var.environment}/config"
  type  = "String"
  value = jsonencode({
    project_name = var.project_name
    environment  = var.environment
    region       = var.aws_region
    state_bucket = aws_s3_bucket.platform_state.id
    state_table  = aws_dynamodb_table.platform_state_lock.name
  })
}

# Outputs
output "platform_state_bucket" {
  description = "S3 bucket for platform Terraform state"
  value       = aws_s3_bucket.platform_state.id
}

output "platform_state_lock_table" {
  description = "DynamoDB table for state locking"
  value       = aws_dynamodb_table.platform_state_lock.name
}

output "platform_automation_role_arn" {
  description = "IAM role ARN for platform automation"
  value       = aws_iam_role.platform_automation.arn
}

output "platform_config_parameter" {
  description = "SSM parameter for platform configuration"
  value       = aws_ssm_parameter.platform_config.name
}

