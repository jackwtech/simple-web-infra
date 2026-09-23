# tf state s3 bucket, prevent_destroy true
module "tf_state" {
  source = "./tf-state"

  state_bucket_name = var.project
}
