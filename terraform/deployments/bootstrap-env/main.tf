terraform {
    required_version = "~> 1.2.7"

    required_providers {
        aws = {
            version = ">= 4.3"
            source  = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = var.region
    profile = "terraform-env-bootstrap-${terraform.workspace}"
}

data "aws_iam_policy_document" "terraform_deploy_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.terraform_provision_account}:role/TerraformProvision"]
    }
  }
}

resource "aws_iam_role" "terraform_deploy_role" {
  name               = "TerraformDeploy"
  assume_role_policy = data.aws_iam_policy_document.terraform_deploy_assume_role.json
}

# Add the terraform deployment related permissions to the role

resource "aws_iam_role_policy_attachment" "terraform_deploy" {
  role       = aws_iam_role.terraform_deploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
