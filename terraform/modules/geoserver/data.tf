resource "aws_iam_role" "appstream_geoserver_data_sync_lambda" {
  name = "appstream_geoserver_data_sync_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.appstream_geoserver_data_sync_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_can_read_appstream_shared_s3" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*"
    ]

    resources = [
      "arn:aws:s3:::${var.shared_bucket_name}",
      "arn:aws:s3:::${var.shared_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_can_read_appstream_shared_s3" {
  name   = "${var.name}-lambda-can-read-appstream-shared-s3"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_can_read_appstream_shared_s3.json
}

resource "aws_iam_role_policy_attachment" "lambda_can_read_appstream_shared_s3" {
  role       = aws_iam_role.appstream_geoserver_data_sync_lambda.name
  policy_arn = aws_iam_policy.lambda_can_read_appstream_shared_s3.arn
}

data "aws_iam_policy_document" "lambda_can_access_efs" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]

    resources = ["*"]
  }
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"

      values = [aws_efs_access_point.access_point.arn]
    }
  }
}

resource "aws_iam_policy" "lambda_can_access_efs" {
  name   = "${var.name}-lambda-can-access-efs"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_can_access_efs.json
}

resource "aws_iam_role_policy_attachment" "lambda_can_access_efs" {
  role       = aws_iam_role.appstream_geoserver_data_sync_lambda.name
  policy_arn = aws_iam_policy.lambda_can_access_efs.arn
}

data "archive_file" "appstream_geoserver_data_sync_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/appstream_geoserver_data_sync_lambda"
  output_path = "${path.module}/appstream_geoserver_data_sync.zip"
}

resource "aws_lambda_function" "appstream_geoserver_data_sync" {
  filename         = data.archive_file.appstream_geoserver_data_sync_lambda_zip.output_path
  runtime          = "python3.8"
  timeout          = 300
  function_name    = "appstream_geoserver_data_sync"
  role             = aws_iam_role.appstream_geoserver_data_sync_lambda.arn
  handler          = "main.handler"
  source_code_hash = filebase64sha256(data.archive_file.appstream_geoserver_data_sync_lambda_zip.output_path)

  environment {
    variables = {
      BUCKET_NAME = var.shared_bucket_name
    }
  }

  file_system_config {
    arn              = aws_efs_access_point.access_point.arn
    local_mount_path = "/mnt/geoserver"
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.efs_mount_target.id]
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.appstream_geoserver_data_sync.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.shared_bucket_name}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.shared_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.appstream_geoserver_data_sync.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*", "s3:ObjectRestore:*", "s3:ObjectAcl:Put"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
