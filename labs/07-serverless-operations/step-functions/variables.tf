# step-functions/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_arns" {
  description = "Map of Lambda function ARNs"
  type        = map(string)
}

