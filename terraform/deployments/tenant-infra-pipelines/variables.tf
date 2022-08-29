# variable "account_roles" {
#   description = "Roles for TF to assume into the relevant account based on the workspace"
#   type        = map(string)
# }

variable "new_account_roles" {
  description = "Roles for TF to assume into the relevant account based on the workspace"
  type        = map(string)
}

# we have to pass the tenant parmeters as a list for ex: ["SitCen", "IPA", "CDDO"]
variable "tenant" {
  type = list(any)
}

# we have to pass the tenant parmeters as a list for ex: ["dsisupportgroup@digital.cabinet-office.gov.uk"]
variable "endpoint" {
  type    = list(any)
  default = ["dsisupportgroup@digital.cabinet-office.gov.uk", "aaron.robson@digital.cabinet-office.gov.uk"]
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


variable "log_group_retention" {
  default = 90
}
