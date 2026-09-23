# tf state s3 bucket, prevent_destroy true
module "tf_state" {
  source = "./tf-state"

  state_bucket_name = var.project
}

module "network" {
  source = "./network"

  project            = var.project
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}
