resource "aws_kms_key" "backup_key" {
  description             = "Backup KMS key"
  deletion_window_in_days = 10
}

resource "aws_backup_vault" "backup_vault" {
  name        = "backup-vault"
  kms_key_arn = aws_kms_key.backup_key.arn
}

resource "aws_iam_role" "backup_vault_iam_role" {
  name               = "backup_vault_iam_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "template_file" "backup_iam_policy" {
  template     = file("./policies/policy.json.tpl")
}
resource "aws_iam_policy" "backup_iam_policy" {
  policy      = file("./policies/policy.json.tpl")
}


resource "aws_iam_role_policy_attachment" "backup_vault_iam_role_policy_attachment" {
  role       = aws_iam_role.backup_vault_iam_role.name
  policy_arn = aws_iam_policy.backup_iam_policy.arn
}

resource "aws_backup_selection" "vault_backup_selection" {
  iam_role_arn = aws_iam_role.backup_vault_iam_role.arn
  name         = "back-selection"
  plan_id      = aws_backup_plan.backup_vault_plan.id
  resources = [
      "arn:aws:s3:::all-${terraform.workspace}-tenant-scripts-bucket",
      "arn:aws:s3:::all-${terraform.workspace}-tenant-bucket",
      "arn:aws:s3:::all-${terraform.workspace}-tenant-landing-bucket"
  ]
}


resource "aws_backup_plan" "backup_vault_plan" {
  name = "aws-backup-plan"
rule {
    rule_name         = "nightly"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(00 16 * * ? *)"
    start_window      = 60
    completion_window = 120
  }
}

