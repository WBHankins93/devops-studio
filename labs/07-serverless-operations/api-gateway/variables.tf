# api-gateway/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "api_handler_arn" {
  description = "ARN of the API handler Lambda function"
  type        = string
}

variable "api_handler_name" {
  description = "Name of the API handler Lambda function"
  type        = string
}

