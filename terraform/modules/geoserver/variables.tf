variable "name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "vpc_id" {
  type      = string
  sensitive = true
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  sensitive   = true
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  sensitive   = true
}

variable "shared_bucket_name" {
  description = "Shared bucket from which to copy files to geoserver"
  type        = string
}

variable "hosted_zone_name" {
  type = string
}

variable "sub_domain_name" {
  description = "To create a record in the Hosted Zone to the ALB"
  type        = string
}

data "aws_region" "current" {}

data "aws_route53_zone" "co" {
  name         = var.hosted_zone_name
  private_zone = false
}
