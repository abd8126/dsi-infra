module "geoserver" {
  source = "../../modules/geoserver"

  name               = "dsi-geoserver-${terraform.workspace}"
  vpc_id             = data.terraform_remote_state.base.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.base.outputs.public_subnet_ids
  sub_domain_name    = "geo"
  hosted_zone_name   = terraform.workspace == "prod" ? "dsi.cabinetoffice.gov.uk" : "${terraform.workspace}.dsi.cabinetoffice.gov.uk"
  shared_bucket_name = module.qgis.shared_bucket_name
}

module "qgis" {
  source = "../../modules/appstream"

  vpc_id              = data.terraform_remote_state.base.outputs.vpc_id
  appstream_image_arn = "arn:aws:appstream:eu-west-2:${data.aws_caller_identity.current.account_id}:image/QGIS"
}
