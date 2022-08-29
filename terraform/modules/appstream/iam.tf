data "aws_iam_policy_document" "okta_appstream_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithSAML"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/okta_appstream"]
    }

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"

      values = [
        "https://signin.aws.amazon.com/saml"
      ]
    }
  }
}

resource "aws_iam_role" "okta_appstream" {
  name                = "okta_appstream"
  assume_role_policy  = data.aws_iam_policy_document.okta_appstream_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonAppStreamFullAccess"]
}

data "aws_iam_policy_document" "appstream_fleet_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["appstream.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "appstream_fleet" {
  name                = "appstream_fleet"
  assume_role_policy  = data.aws_iam_policy_document.appstream_fleet_assume_role_policy.json
}

data "aws_iam_policy_document" "appstream_fleet_s3_access" {
  statement {
    sid    = "AppstreamCanDoAnythingInSharedBucket"
    effect = "Allow"

    actions   = [
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.appstream.arn,
      "${aws_s3_bucket.appstream.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "appstream_fleet_s3_access" {
  name   = "appstream_fleet_s3_access"
  path   = "/"
  policy = data.aws_iam_policy_document.appstream_fleet_s3_access.json
}

resource "aws_iam_role_policy_attachment" "appstream_fleet_s3_access" {
  role       = aws_iam_role.appstream_fleet.name
  policy_arn = aws_iam_policy.appstream_fleet_s3_access.arn
}
