variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "Two public subnets in distinct AZs, with working internet routes."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) == 2 && length(distinct(var.public_subnet_ids)) == 2
    error_message = "Provide two distinct public subnet IDs in different availability zones."
  }
}

variable "image_tag" {
  description = "Docker Hub official NGINX tag; must support ARM64."
  type        = string
  default     = "stable-alpine3.24-slim"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$", var.image_tag))
    error_message = "image_tag must be a valid Docker image tag (1-128 characters)."
  }
}
