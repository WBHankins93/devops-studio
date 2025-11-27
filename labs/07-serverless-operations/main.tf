# main.tf
# Serverless Operations Lab - Main Infrastructure Configuration

terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
  
  # Uncomment and configure if using remote state
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "devops-studio/lab-07-serverless/terraform.tfstate"
  #   region = "us-west-2"
  # }
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
        Lab         = "07-serverless-operations"
      }
    )
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# S3 bucket for Lambda deployment packages
resource "aws_s3_bucket" "lambda_deployments" {
  bucket = "${var.project_name}-${var.environment}-lambda-deployments-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "lambda_deployments" {
  bucket = aws_s3_bucket.lambda_deployments.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_deployments" {
  bucket = aws_s3_bucket.lambda_deployments.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_execution" {
  name = "${var.project_name}-${var.environment}-lambda-execution-role"
  
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

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Additional permissions for Lambda functions
resource "aws_iam_role_policy" "lambda_additional" {
  name = "${var.project_name}-${var.environment}-lambda-additional-permissions"
  role = aws_iam_role.lambda_execution.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.events.arn,
          "${aws_dynamodb_table.events.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.lambda_deployments.arn}/*"
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

# Archive Lambda function code
data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "${path.module}/lambda/hello-world/lambda_function.py"
  output_path = "${path.module}/lambda/hello-world/function.zip"
}

data "archive_file" "api_handler" {
  type        = "zip"
  source_file = "${path.module}/lambda/api-handler/lambda_function.py"
  output_path = "${path.module}/lambda/api-handler/function.zip"
}

data "archive_file" "event_processor" {
  type        = "zip"
  source_file = "${path.module}/lambda/event-processor/lambda_function.py"
  output_path = "${path.module}/lambda/event-processor/function.zip"
}

# Lambda: Hello World
resource "aws_lambda_function" "hello_world" {
  function_name = "${var.project_name}-${var.environment}-hello-world"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 128
  
  filename         = data.archive_file.hello_world.output_path
  source_code_hash = data.archive_file.hello_world.output_base64sha256
  
  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_cloudwatch_log_group.hello_world
  ]
}

# Lambda: API Handler
resource "aws_lambda_function" "api_handler" {
  function_name = "${var.project_name}-${var.environment}-api-handler"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 30
  memory_size   = 256
  
  filename         = data.archive_file.api_handler.output_path
  source_code_hash = data.archive_file.api_handler.output_base64sha256
  
  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_cloudwatch_log_group.api_handler
  ]
}

# Lambda: Event Processor
resource "aws_lambda_function" "event_processor" {
  function_name = "${var.project_name}-${var.environment}-event-processor"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 256
  
  filename         = data.archive_file.event_processor.output_path
  source_code_hash = data.archive_file.event_processor.output_base64sha256
  
  environment {
    variables = {
      ENVIRONMENT        = var.environment
      EVENTS_TABLE_NAME  = aws_dynamodb_table.events.name
    }
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_cloudwatch_log_group.event_processor
  ]
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "hello_world" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-hello-world"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "api_handler" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-api-handler"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "event_processor" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-event-processor"
  retention_in_days = var.log_retention_days
}

# DynamoDB Table for Events
resource "aws_dynamodb_table" "events" {
  name           = "${var.project_name}-${var.environment}-events"
  billing_mode  = "PAY_PER_REQUEST" # On-demand pricing
  hash_key      = "event_id"
  
  attribute {
    name = "event_id"
    type = "S"
  }
  
  attribute {
    name = "timestamp"
    type = "S"
  }
  
  # Global Secondary Index for querying by timestamp
  global_secondary_index {
    name     = "timestamp-index"
    hash_key = "timestamp"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-events"
  }
}

# Include API Gateway configuration
module "api_gateway" {
  source = "./api-gateway"
  
  project_name   = var.project_name
  environment    = var.environment
  api_handler_arn = aws_lambda_function.api_handler.arn
  api_handler_name = aws_lambda_function.api_handler.function_name
}

# Include EventBridge configuration
module "eventbridge" {
  source = "./eventbridge"
  
  project_name        = var.project_name
  environment         = var.environment
  event_processor_arn = aws_lambda_function.event_processor.arn
}

# Include Step Functions configuration
module "step_functions" {
  source = "./step-functions"
  
  project_name   = var.project_name
  environment    = var.environment
  lambda_arns = {
    hello_world = aws_lambda_function.hello_world.arn
    api_handler = aws_lambda_function.api_handler.arn
  }
}

