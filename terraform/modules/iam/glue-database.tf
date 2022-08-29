resource "aws_glue_catalog_database" "tenant_database" {
  count  = length(var.tenant)
  name =  lower("${var.tenant[count.index]}_database")
}
resource "aws_glue_catalog_database" "tenant_landing_database" {
  count  = length(var.tenant)
  name =  lower("${var.tenant[count.index]}_landing_database")
}