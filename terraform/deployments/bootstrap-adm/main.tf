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
    profile = "terraform-adm-bootstrap"
}

module "remote_state" {
    source = "nozaq/remote-state-s3-backend/aws"
    enable_replication = false
    providers = {
        aws = aws
        aws.replica = aws
    }
}

# resource "aws_iam_user" "terraform" {
#     name = "TerraformUser"
# }

# resource "aws_iam_user_policy_attachment" "remote_state_access" {
#     user = aws_iam_user.terraform.name
#     policy_arn = module.remote_state.terraform_iam_policy.arn
# }

# Set up OIDC for auth with Github Actions

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Set up a role which allows the OIDC provider to assume it

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
						"repo:cabinetoffice/dsi-infrastructure:ref:refs/heads/main",
						"repo:cabinetoffice/dsi-collab:ref:refs/heads/main",
						"repo:cabinetoffice/dsi-collab-framework:ref:refs/heads/main"
      ]
    }
  }
}


resource "aws_iam_role" "github_actions" {
  name               = "TerraformProvision"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

# Add the terraform related permissions to the role

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = module.remote_state.terraform_iam_policy.arn
}

data "aws_iam_policy_document" "terraform_role_chaining" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    resources = ["arn:aws:iam::*:role/TerraformDeploy"]
  }
}

resource "aws_iam_policy" "terraform_assume_deploy" {
  name = "terraform_assume_deploy"
  path = "/"
  policy = data.aws_iam_policy_document.terraform_role_chaining.json
}

resource "aws_iam_role_policy_attachment" "terraform_role_chaining" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.terraform_assume_deploy.arn
}
