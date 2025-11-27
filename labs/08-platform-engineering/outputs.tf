# outputs.tf
# Output values for Platform Engineering Lab

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

output "next_steps" {
  description = "Next steps for setting up the platform"
  value = <<-EOT
    Platform infrastructure has been deployed!
    
    Next steps:
    1. Review service catalog templates in service-catalog/
    2. Set up developer portal (see portal/README.md)
    3. Configure platform APIs (see platform-api/README.md)
    4. Set up monitoring dashboards (see monitoring/README.md)
    
    For detailed setup instructions, see the main README.md
  EOT
}

