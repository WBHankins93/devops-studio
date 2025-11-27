# eventbridge/main.tf
# EventBridge configuration for event-driven architecture

# Custom EventBridge Bus
resource "aws_cloudwatch_event_bus" "custom" {
  name = "${var.project_name}-${var.environment}-bus"
}

# EventBridge Rule: Scheduled Event (every 5 minutes)
resource "aws_cloudwatch_event_rule" "scheduled" {
  name                = "${var.project_name}-${var.environment}-scheduled-rule"
  description         = "Trigger event processor every 5 minutes"
  schedule_expression = "rate(5 minutes)"
  
  event_bus_name = aws_cloudwatch_event_bus.custom.name
}

# EventBridge Rule: Custom Events
resource "aws_cloudwatch_event_rule" "custom_events" {
  name        = "${var.project_name}-${var.environment}-custom-rule"
  description = "Route custom events to event processor"
  
  event_bus_name = aws_cloudwatch_event_bus.custom.name
  
  event_pattern = jsonencode({
    source      = ["${var.project_name}.${var.environment}"]
    detail-type = ["Custom Event"]
  })
}

# EventBridge Target: Lambda Function
resource "aws_cloudwatch_event_target" "event_processor" {
  rule      = aws_cloudwatch_event_rule.scheduled.name
  target_id = "EventProcessorLambda"
  arn       = var.event_processor_arn
  
  event_bus_name = aws_cloudwatch_event_bus.custom.name
}

# Lambda permission for EventBridge
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.event_processor_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled.arn
}

# EventBridge Target: Custom Events
resource "aws_cloudwatch_event_target" "custom_events" {
  rule      = aws_cloudwatch_event_rule.custom_events.name
  target_id = "CustomEventsLambda"
  arn       = var.event_processor_arn
  
  event_bus_name = aws_cloudwatch_event_bus.custom.name
}

# Lambda permission for custom events
resource "aws_lambda_permission" "custom_events" {
  statement_id  = "AllowExecutionFromCustomEvents"
  action        = "lambda:InvokeFunction"
  function_name = var.event_processor_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.custom_events.arn
}

# Outputs
output "event_bus_name" {
  description = "EventBridge bus name"
  value       = aws_cloudwatch_event_bus.custom.name
}

output "event_bus_arn" {
  description = "EventBridge bus ARN"
  value       = aws_cloudwatch_event_bus.custom.arn
}

output "scheduled_rule_arn" {
  description = "Scheduled rule ARN"
  value       = aws_cloudwatch_event_rule.scheduled.arn
}

