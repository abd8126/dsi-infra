resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name
  }
}

resource "aws_eip" "nat_gateway" {
  vpc   = true
  count = length(var.availability_zones)

  tags = {
    Name = var.name
  }
}
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = element(aws_eip.nat_gateway.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]
  count         = length(var.availability_zones)

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "vpc-endpoint-${var.name}"
  description = "SG for VPC interface endpoints"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "vpc_endpoint_internal" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.vpc_endpoint.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id             = aws_vpc.vpc.id
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private.*.id
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id             = aws_vpc.vpc.id
  vpc_endpoint_type  = "Interface"
  subnet_ids         = aws_subnet.private.*.id
  security_group_ids = [aws_security_group.vpc_endpoint.id]
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
}
