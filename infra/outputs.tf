output "state_bucket_name" {
  description = "tf state bucket name"
  value       = module.tf_state.state_bucket_name
}

output "vpc_id" {
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets in 2 AZs"
  value       = module.network.public_subnet_ids
}
