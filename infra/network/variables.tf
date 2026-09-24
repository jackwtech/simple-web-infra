variable "project" {
  type = string
}

variable "vpc_cidr" {
  description = "IPv4 VPC CIDR prefix /16 range"
  type        = string
}

variable "availability_zones" {
  type = list(string)
}
