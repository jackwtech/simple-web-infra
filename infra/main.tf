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

module "web_app" {
  source = "./web-app"

  project           = var.project
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  image_tag         = var.web_app_image_tag
}
