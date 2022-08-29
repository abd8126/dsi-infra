resource "aws_iam_saml_provider" "SelfAdmin" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}SelfAdmin"
  saml_metadata_document = file("./saml/Okta_Tenant.xml")
}

resource "aws_iam_saml_provider" "AdminReadOnly" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}AdminReadOnly"
  saml_metadata_document = file("./saml/Okta_Tenant.xml")
}

resource "aws_iam_saml_provider" "PreLanding" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}PreLanding"
  saml_metadata_document = file("./saml/Okta_Tenant.xml")
}
