resource "aws_cloudwatch_log_group" "tenant_log_group" { 
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}GlueLogGroup"
  retention_in_days = var.log_group_retention
}