resource "aws_secretsmanager_secret" "tenant" {
  count = length(var.tenant)
  name  = "${terraform.workspace}/${var.tenant[count.index]}/ETLGlue"
}