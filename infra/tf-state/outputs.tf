output "state_bucket_name" {
  description = "tf state"
  value       = aws_s3_bucket.tf_state.id
}

output "state_bucket_arn" {
  description = "tf state arn"
  value       = aws_s3_bucket.tf_state.arn
}
