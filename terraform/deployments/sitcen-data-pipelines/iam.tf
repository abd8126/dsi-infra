data "aws_iam_policy_document" "glue_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sitcen_glue_jobs" {
  name               = "sitcen-glue-jobs"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy.json
}

data "aws_iam_policy_document" "glue_can_access_data" {
  statement {
    sid       = "CanGetGlueScript"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name}/sitcen/*"]
  }

  statement {
    sid = "CanAccessDataBuckets"
    actions = [
      "s3:ListBucket",
      "s3:*Object*"
    ]
    resources = [
      "arn:aws:s3:::${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}",
      "arn:aws:s3:::${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}",
      "arn:aws:s3:::${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/sitcen/*",
      "arn:aws:s3:::${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/sitcen/repository/*"
    ]
  }

  statement {
    sid = "CanAccessGlue"
    actions = [
      "glue:GetTable",
      "glue:GetPartition",
      "glue:GetPartitions"
    ]
    resources = [
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:catalog",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:database/${data.terraform_remote_state.base.outputs.landing_glue_database_name}",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:table/${data.terraform_remote_state.base.outputs.landing_glue_database_name}/*",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:database/${data.terraform_remote_state.base.outputs.data_repository_glue_database_name}",
      "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:table/${data.terraform_remote_state.base.outputs.data_repository_glue_database_name}/*"
    ]
  }

  statement {
    sid = "CanUseConnection"
    actions = [
      "glue:GetConnection",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeRouteTables",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "glue_can_access_data" {
  name   = "can-access-data"
  role   = aws_iam_role.sitcen_glue_jobs.id
  policy = data.aws_iam_policy_document.glue_can_access_data.json
}

data "aws_iam_policy_document" "glue_can_write_logs_and_metrics" {
  statement {
    sid = "CanWriteLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:/aws-glue/*"]
  }

  statement {
    sid       = "CanPutMetricData"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "glue_can_write_logs_and_metrics" {
  name   = "glue-can-write-logs-and-metrics"
  role   = aws_iam_role.sitcen_glue_jobs.id
  policy = data.aws_iam_policy_document.glue_can_write_logs_and_metrics.json
}

data "aws_iam_policy_document" "glue_can_get_secret" {
  statement {
    sid = "CanGetSecret"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:secret:DSI/*"]
  }
}

resource "aws_iam_role_policy" "glue_can_get_secret" {
  name   = "glue-can-get-secret"
  role   = aws_iam_role.sitcen_glue_jobs.id
  policy = data.aws_iam_policy_document.glue_can_get_secret.json
}
