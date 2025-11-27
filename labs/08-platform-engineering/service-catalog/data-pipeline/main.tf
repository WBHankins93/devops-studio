# service-catalog/data-pipeline/main.tf
# Data Pipeline Template - Main Configuration

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Variables
variable "pipeline_name" {
  description = "Pipeline name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
}

variable "source_bucket" {
  description = "Source S3 bucket for raw data"
  type        = string
}

variable "destination_bucket" {
  description = "Destination S3 bucket for processed data"
  type        = string
}

variable "schedule" {
  description = "Execution schedule (cron expression)"
  type        = string
  default     = "cron(0 2 * * ? *)"  # Daily at 2 AM
}

# S3 Bucket for raw data (if not provided)
resource "aws_s3_bucket" "source" {
  count  = var.source_bucket == "" ? 1 : 0
  bucket = "${var.pipeline_name}-${var.environment}-source"
}

resource "aws_s3_bucket_versioning" "source" {
  count  = var.source_bucket == "" ? 1 : 0
  bucket = aws_s3_bucket.source[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket for processed data (if not provided)
resource "aws_s3_bucket" "destination" {
  count  = var.destination_bucket == "" ? 1 : 0
  bucket = "${var.pipeline_name}-${var.environment}-destination"
}

resource "aws_s3_bucket_versioning" "destination" {
  count  = var.destination_bucket == "" ? 1 : 0
  bucket = aws_s3_bucket.destination[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM Role for Glue
resource "aws_iam_role" "glue" {
  name = "${var.pipeline_name}-${var.environment}-glue-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Glue
resource "aws_iam_role_policy" "glue" {
  name = "${var.pipeline_name}-${var.environment}-glue-policy"
  role = aws_iam_role.glue.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.source_bucket != "" ? var.source_bucket : aws_s3_bucket.source[0].id}/*",
          "arn:aws:s3:::${var.destination_bucket != "" ? var.destination_bucket : aws_s3_bucket.destination[0].id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Glue Job
resource "aws_glue_job" "pipeline" {
  name     = "${var.pipeline_name}-${var.environment}-job"
  role_arn = aws_iam_role.glue.arn
  
  command {
    script_location = "s3://${var.source_bucket != "" ? var.source_bucket : aws_s3_bucket.source[0].id}/scripts/etl_script.py"
    python_version  = "3"
  }
  
  default_arguments = {
    "--TempDir" = "s3://${var.source_bucket != "" ? var.source_bucket : aws_s3_bucket.source[0].id}/temp/"
    "--job-language" = "python"
    "--job-bookmark-option" = "job-bookmark-enable"
  }
  
  max_retries = 2
  timeout     = 60
  
  tags = {
    Name = "${var.pipeline_name}-${var.environment}-job"
  }
}

# EventBridge Rule for scheduled execution
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.pipeline_name}-${var.environment}-schedule"
  description         = "Schedule for ${var.pipeline_name} pipeline"
  schedule_expression = var.schedule
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "glue_job" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "GlueJobTarget"
  arn       = aws_glue_job.pipeline.arn
  role_arn  = aws_iam_role.eventbridge.arn
}

# IAM Role for EventBridge
resource "aws_iam_role" "eventbridge" {
  name = "${var.pipeline_name}-${var.environment}-eventbridge-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge" {
  name = "${var.pipeline_name}-${var.environment}-eventbridge-policy"
  role = aws_iam_role.eventbridge.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun"
        ]
        Resource = aws_glue_job.pipeline.arn
      }
    ]
  })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "glue" {
  name              = "/aws-glue/jobs/${var.pipeline_name}-${var.environment}"
  retention_in_days = 7
}

# Outputs
output "glue_job_name" {
  description = "Glue job name"
  value       = aws_glue_job.pipeline.name
}

output "source_bucket_name" {
  description = "Source bucket name"
  value       = var.source_bucket != "" ? var.source_bucket : aws_s3_bucket.source[0].id
}

output "destination_bucket_name" {
  description = "Destination bucket name"
  value       = var.destination_bucket != "" ? var.destination_bucket : aws_s3_bucket.destination[0].id
}

output "schedule_rule_arn" {
  description = "EventBridge schedule rule ARN"
  value       = aws_cloudwatch_event_rule.schedule.arn
}

