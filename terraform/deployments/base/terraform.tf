provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn     = var.account_roles[terraform.workspace]
    session_name = "terraform"
  }
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      version = ">= 4.0.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "co-dsi-terraform-state"
    key    = "base.tfstate"
    region = "eu-west-2"
  }
}
