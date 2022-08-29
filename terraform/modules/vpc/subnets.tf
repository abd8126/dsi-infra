resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id

  # with VPC CIDR of 10.0.0.0/16 and three AZs, returns:
  # 10.0.0.0/24, 10.0.4.0/24, 10.0.8.0/24
  cidr_block = cidrsubnet(var.cidr, 8, count.index * 4)

  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.availability_zones)

  tags = {
    Name = "public-${element(var.availability_zones, count.index)}.${var.name}"
    type = "public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
  count          = length(var.availability_zones)
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc.id

  # with VPC CIDR of 10.0.0.0/16 and three AZs, returns:
  # 10.0.10.0/24, 10.0.14.0/24, 10.0.18.0/24
  cidr_block = cidrsubnet(var.cidr, 8, count.index * 4 + 10)

  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.availability_zones)

  tags = {
    Name = "private-${element(var.availability_zones, count.index)}.${var.name}"
    type = "private"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  count          = length(var.availability_zones)
}
