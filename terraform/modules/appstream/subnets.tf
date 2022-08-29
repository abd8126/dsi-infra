# Appstream is not supported in euw2-az3

data "aws_subnet" "az1" {
  availability_zone_id = "euw2-az1"
  vpc_id               = var.vpc_id
  tags = {
    type = "private"
  }
}

data "aws_subnet" "az2" {
  availability_zone_id = "euw2-az2"
  vpc_id               = var.vpc_id
  tags = {
    type = "private"
  }
}
