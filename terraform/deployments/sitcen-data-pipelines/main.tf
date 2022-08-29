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
    key    = "sitcen-data-pipelines.tfstate"
    region = "eu-west-2"
  }
}


data "terraform_remote_state" "base" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "co-dsi-terraform-state"
    key    = "base.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "tenant" {
  backend   = "s3"
  workspace = terraform.workspace
  config = {
    bucket = "co-dsi-terraform-state"
    key    = "tenant-infra-pipelines.tfstate"
    region = "eu-west-2"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
