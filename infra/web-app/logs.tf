resource "aws_cloudwatch_log_group" "this" {
  name              = "/${var.project}/web-app"
  retention_in_days = 1 # min retention to save cost
}
