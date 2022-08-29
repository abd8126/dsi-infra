resource "aws_efs_file_system" "efs" {

  encrypted = true
  tags = {
    Name = var.name
  }
}

resource "aws_efs_mount_target" "mount_target" {

  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs_mount_target.id]
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.efs.id

  posix_user {
    uid = 1000
    gid = 10001
  }

  root_directory {
    path = "/geoserver-data-dir"

    creation_info {
      owner_uid   = 1000
      owner_gid   = 10001
      permissions = 0777
    }
  }
}

resource "aws_security_group" "efs_mount_target" {
  name        = "${var.name}-efs-mount-target"
  description = "Used for EFS mount targets"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "efs_self_reference_ingress" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.efs_mount_target.id
}

resource "aws_security_group_rule" "efs_ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.geoserver.id
  security_group_id        = aws_security_group.efs_mount_target.id
}

resource "aws_security_group_rule" "efs_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.efs_mount_target.id
}
