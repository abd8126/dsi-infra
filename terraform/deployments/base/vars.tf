variable "account_roles" {
  description = "Roles for TF to assume into the relevant account based on the workspace"
  type        = map(string)
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type = list(string)

  default = [
    "eu-west-2a",
    "eu-west-2b",
    "eu-west-2c",
  ]
}
variable "noncurrentdelete" {
  type    = number
  default = 90
}
