# step-functions/main.tf
# Step Functions state machine for workflow orchestration

# IAM Role for Step Functions
resource "aws_iam_role" "step_functions" {
  name = "${var.project_name}-${var.environment}-step-functions-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Step Functions to invoke Lambda
resource "aws_iam_role_policy" "step_functions" {
  name = "${var.project_name}-${var.environment}-step-functions-policy"
  role = aws_iam_role.step_functions.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = values(var.lambda_arns)
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# Step Functions State Machine Definition
resource "aws_sfn_state_machine" "workflow" {
  name     = "${var.project_name}-${var.environment}-workflow"
  role_arn = aws_iam_role.step_functions.arn
  
  definition = jsonencode({
    Comment = "Serverless workflow orchestration"
    StartAt = "HelloWorld"
    States = {
      HelloWorld = {
        Type     = "Task"
        Resource = var.lambda_arns.hello_world
        Next     = "ApiHandler"
        Retry = [
          {
            ErrorEquals     = ["States.ALL"]
            IntervalSeconds = 2
            MaxAttempts     = 3
            BackoffRate     = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "ErrorHandler"
            ResultPath  = "$.error"
          }
        ]
      }
      ApiHandler = {
        Type     = "Task"
        Resource = var.lambda_arns.api_handler
        Input = {
          "httpMethod" = "POST"
          "path"       = "/process"
          "body"       = {
            "message" = "Processed by Step Functions"
            "previous" = "$.Payload"
          }
        }
        End = true
        Retry = [
          {
            ErrorEquals     = ["States.ALL"]
            IntervalSeconds = 2
            MaxAttempts     = 3
            BackoffRate     = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "ErrorHandler"
            ResultPath  = "$.error"
          }
        ]
      }
      ErrorHandler = {
        Type = "Fail"
        Error = "WorkflowError"
        Cause = "An error occurred in the workflow"
      }
    }
  })
  
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-workflow"
  }
}

# CloudWatch Log Group for Step Functions
resource "aws_cloudwatch_log_group" "step_functions" {
  name              = "/aws/vendedlogs/states/${var.project_name}-${var.environment}-workflow"
  retention_in_days = 7
}

# Outputs
output "state_machine_arn" {
  description = "Step Functions state machine ARN"
  value       = aws_sfn_state_machine.workflow.arn
}

output "state_machine_name" {
  description = "Step Functions state machine name"
  value       = aws_sfn_state_machine.workflow.name
}

