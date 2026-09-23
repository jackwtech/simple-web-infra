variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "project" {
  type    = string
  default = "simple-web-infra"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR for the VPC, with a prefix length between /16 and /20."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Two distinct AZs in aws_region, in subnet allocation order."
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
}
