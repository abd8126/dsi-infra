resource "aws_security_group" "appstream" {
  name        = "appstream"
  description = "SG for QGIS Appstream Fleet"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    tenant = "sitcen"
  }
}

resource "aws_security_group_rule" "self_reference_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  self              = true
  security_group_id = aws_security_group.appstream.id
}

resource "aws_security_group_rule" "open_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.appstream.id
}
