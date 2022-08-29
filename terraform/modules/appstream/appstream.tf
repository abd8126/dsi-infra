resource "aws_appstream_fleet" "qgis" {
  name = "QGIS"

  compute_capacity {
    desired_instances = terraform.workspace == "prod" ? 10 : 2
  }

  stream_view                        = "APP"
  idle_disconnect_timeout_in_seconds = 3600  # 1 hour
  max_user_duration_in_seconds       = 36000 # 10 hours
  disconnect_timeout_in_seconds      = 1800  # 30 minutes
  display_name                       = "QGIS"
  fleet_type                         = "ON_DEMAND"
  iam_role_arn                       = aws_iam_role.appstream_fleet.arn
  image_arn                          = var.appstream_image_arn
  instance_type                      = terraform.workspace == "prod" ? "stream.compute.2xlarge" : "stream.standard.small"

  vpc_config {
    subnet_ids         = [data.aws_subnet.az1.id, data.aws_subnet.az2.id]
    security_group_ids = [aws_security_group.appstream.id]
  }
}

resource "aws_appstream_stack" "qgis" {
  name = "QGIS"

  storage_connectors {
    connector_type = "HOMEFOLDERS"
  }

  user_settings {
    action     = "CLIPBOARD_COPY_FROM_LOCAL_DEVICE"
    permission = "ENABLED"
  }
  user_settings {
    action     = "CLIPBOARD_COPY_TO_LOCAL_DEVICE"
    permission = "ENABLED"
  }
  user_settings {
    action     = "FILE_UPLOAD"
    permission = "ENABLED"
  }
  user_settings {
    action     = "FILE_DOWNLOAD"
    permission = "ENABLED"
  }
  user_settings {
    action     = "DOMAIN_PASSWORD_SIGNIN"
    permission = "ENABLED"
  }
  user_settings {
    action     = "DOMAIN_SMART_CARD_SIGNIN"
    permission = "DISABLED"
  }
  user_settings {
    action     = "PRINTING_TO_LOCAL_DEVICE"
    permission = "ENABLED"
  }

  application_settings {
    enabled        = true
    settings_group = "SettingsGroup"
  }
}

resource "aws_appstream_fleet_stack_association" "qgis" {
  fleet_name = aws_appstream_fleet.qgis.name
  stack_name = aws_appstream_stack.qgis.name
}
