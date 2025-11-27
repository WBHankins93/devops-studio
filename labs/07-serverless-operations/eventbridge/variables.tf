# eventbridge/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "event_processor_arn" {
  description = "ARN of the event processor Lambda function"
  type        = string
}

