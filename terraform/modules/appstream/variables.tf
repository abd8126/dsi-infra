data "aws_caller_identity" "current" {}

variable "vpc_id" {
  type = string
}

variable "appstream_image_arn" {
  type = string
}
