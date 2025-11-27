# outputs.tf
# Output values for Serverless Operations Lab

output "lambda_functions" {
  description = "Lambda function ARNs and names"
  value = {
    hello_world = {
      arn  = aws_lambda_function.hello_world.arn
      name = aws_lambda_function.hello_world.function_name
    }
    api_handler = {
      arn  = aws_lambda_function.api_handler.arn
      name = aws_lambda_function.api_handler.function_name
    }
    event_processor = {
      arn  = aws_lambda_function.event_processor.arn
      name = aws_lambda_function.event_processor.function_name
    }
  }
}

output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = var.enable_api_gateway ? module.api_gateway.api_url : null
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for events"
  value       = aws_dynamodb_table.events.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.events.arn
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value = {
    hello_world     = aws_cloudwatch_log_group.hello_world.name
    api_handler     = aws_cloudwatch_log_group.api_handler.name
    event_processor = aws_cloudwatch_log_group.event_processor.name
  }
}

output "s3_bucket_name" {
  description = "S3 bucket name for Lambda deployments"
  value       = aws_s3_bucket.lambda_deployments.id
}

output "step_functions_arn" {
  description = "Step Functions state machine ARN"
  value       = var.enable_step_functions ? module.step_functions.state_machine_arn : null
}

output "invoke_commands" {
  description = "Example AWS CLI commands to invoke Lambda functions"
  value = {
    hello_world = "aws lambda invoke --function-name ${aws_lambda_function.hello_world.function_name} --payload '{\"name\":\"Developer\",\"message\":\"Hello\"}' response.json"
    api_handler = "aws lambda invoke --function-name ${aws_lambda_function.api_handler.function_name} --payload '{\"httpMethod\":\"GET\",\"path\":\"/test\"}' response.json"
    event_processor = "aws lambda invoke --function-name ${aws_lambda_function.event_processor.function_name} --payload '{\"source\":\"test\",\"detail-type\":\"Test Event\"}' response.json"
  }
}

