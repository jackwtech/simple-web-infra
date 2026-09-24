output "url" {
  description = "Public HTTP endpoint."
  value       = "http://${aws_lb.this.dns_name}"
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.this.name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}
