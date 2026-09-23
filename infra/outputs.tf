output "state_bucket_name" {
  description = "tf state bucket name"
  value       = module.tf_state.state_bucket_name
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets in 2 AZs"
  value       = module.network.public_subnet_ids
}

output "web_app_url" {
  description = "Public HTTP endpoint for NGINX."
  value       = module.web_app.url
}


output "web_app_autoscaling_group_name" {
  value = module.web_app.autoscaling_group_name
}

output "web_app_log_group_name" {
  value = module.web_app.log_group_name
}
