terraform {
  required_version = "~> 1.2.7"
  required_providers {
    aws = {
      version = ">= 4.3"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "tf-remote-state20220819223209683200000001"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-west-2:542179038994:key/90062b6a-7552-4363-8e0a-715ef66070d1"
    dynamodb_table = "tf-remote-state-lock"
  }
}

provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn     = var.new_account_roles[terraform.workspace]
    session_name = "terraform"
  }
}

/*
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
    key    = "tenant-infra-pipelines.tfstate"
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
*/

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
