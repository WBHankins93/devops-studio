# modules/web-app/outputs.tf
# Output values from the web application module

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Canonical hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web_app.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_app.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_app.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.web_app.id
}

output "security_group_id" {
  description = "ID of the web application security group"
  value       = aws_security_group.web_app.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role for EC2 instances"
  value       = aws_iam_role.web_app.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.web_app.name
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = var.enable_dashboard ? "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.web_app[0].dashboard_name}" : null
}

# Application URL
output "application_url" {
  description = "URL of the web application"
  value       = "http://${aws_lb.main.dns_name}"
}

# Health check information
output "health_check_url" {
  description = "Health check URL"
  value       = "http://${aws_lb.main.dns_name}${var.health_check_path}"
}

# Configuration summary
output "web_app_config" {
  description = "Web application configuration summary"
  value = {
    load_balancer_dns   = aws_lb.main.dns_name
    autoscaling_group   = aws_autoscaling_group.web_app.name
    instance_type       = var.instance_type
    min_capacity        = var.min_size
    max_capacity        = var.max_size
    desired_capacity    = var.desired_capacity
    health_check_path   = var.health_check_path
    security_group_id   = aws_security_group.web_app.id
  }
}