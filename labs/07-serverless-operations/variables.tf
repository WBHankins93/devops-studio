# variables.tf
# Variable definitions for Serverless Operations Lab

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
  
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention period."
  }
}

variable "lambda_memory_sizes" {
  description = "Memory sizes for Lambda functions (MB)"
  type = map(number)
  default = {
    hello_world     = 128
    api_handler     = 256
    event_processor = 256
  }
}

variable "lambda_timeouts" {
  description = "Timeout values for Lambda functions (seconds)"
  type = map(number)
  default = {
    hello_world     = 30
    api_handler     = 30
    event_processor = 60
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_api_gateway" {
  description = "Enable API Gateway deployment"
  type        = bool
  default     = true
}

variable "enable_eventbridge" {
  description = "Enable EventBridge configuration"
  type        = bool
  default     = true
}

variable "enable_step_functions" {
  description = "Enable Step Functions workflows"
  type        = bool
  default     = true
}

