locals {
  sitcen_gis = {
    name = "sitcen-gis"
  }
}

resource "aws_secretsmanager_secret" "rds_master_credentials" {
  name = local.sitcen_gis.name
}

resource "aws_secretsmanager_secret_version" "rds_master_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_master_credentials.id
  secret_string = <<EOF
{
  "username": "${module.sitcen_gis_aurora_postgresql.cluster_master_username}",
  "password": "${module.sitcen_gis_aurora_postgresql.cluster_master_password}",
  "engine": "postgresql",
  "host": "${module.sitcen_gis_aurora_postgresql.cluster_endpoint}",
  "port": ${module.sitcen_gis_aurora_postgresql.cluster_port},
  "dbClusterIdentifier": "${module.sitcen_gis_aurora_postgresql.cluster_id}"
}
EOF
}


resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "geo-private"
  subnet_ids = data.terraform_remote_state.base.outputs.private_subnet_ids
}

module "sitcen_gis_aurora_postgresql" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "6.1.3"

  name                    = local.sitcen_gis.name
  engine                  = "aurora-postgresql"
  engine_mode             = "serverless"
  storage_encrypted       = true
  backup_retention_period = 7
  copy_tags_to_snapshot   = true
  deletion_protection     = true
  enable_http_endpoint    = true

  db_subnet_group_name    = aws_db_subnet_group.private_subnet_group.name
  create_db_subnet_group  = false
  create_security_group   = true
  allowed_security_groups = [module.qgis.security_group_id, module.geoserver.security_group_id]
  vpc_id                  = data.terraform_remote_state.base.outputs.vpc_id

  monitoring_interval = 60

  auto_minor_version_upgrade       = true
  allow_major_version_upgrade      = false
  apply_immediately                = false
  skip_final_snapshot              = false
  final_snapshot_identifier_prefix = local.sitcen_gis.name
  preferred_backup_window          = "00:00-03:00"
  preferred_maintenance_window     = "tue:04:00-tue:04:30"

  # enabled_cloudwatch_logs_exports = # NOT SUPPORTED

  scaling_configuration = {
    auto_pause     = false
    min_capacity   = 2
    max_capacity   = 32
    timeout_action = "RollbackCapacityChange"
  }
}
