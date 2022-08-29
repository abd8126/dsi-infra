module "tenant-permissions" {
  source              = "../../modules/iam"
  tenant              = var.tenant
  aws-account-id      = data.aws_caller_identity.current.account_id
  aws_region          = "eu-west-2"
  log_group_retention = var.log_group_retention
}

module "vpc" {
  source             = "../../modules/vpc"
  name               = "dsi-base-${terraform.workspace}"
  cidr               = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "sns_glue" {
  source = "../../modules/sns"

  endpoint = var.endpoint
}


module "slack" {
  source = "../../modules/slack"

  env = terraform.workspace
}
