module "vpc" {
  source = "../../modules/vpc"

  name               = "dsi-base-${terraform.workspace}"
  cidr               = var.vpc_cidr
  availability_zones = var.availability_zones
}
