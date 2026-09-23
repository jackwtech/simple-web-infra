# Comment below when first bring up the infra
terraform {
  backend "s3" {
    key          = "tf-state/terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = true
  }
}
