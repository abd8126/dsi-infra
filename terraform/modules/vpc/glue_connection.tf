# Private subnet for glue connection
data "aws_subnet" "glue_connection_private_subnet" {
  id = aws_subnet.private[0].id
}

# VPC where the glue connection will run in. This is to retrieve the default open egress security group
data "aws_security_group" "vpc_default_security_group" {
  name   = "default"
  vpc_id = aws_vpc.vpc.id
}


# Glue connection resource to run a job within a private subnet
resource "aws_glue_connection" "private_subnet" {
  name            = "cqc-private-subnet"
  connection_type = "NETWORK"

  physical_connection_requirements {
    availability_zone      = data.aws_subnet.glue_connection_private_subnet.availability_zone
    security_group_id_list = [data.aws_security_group.vpc_default_security_group.id]
    subnet_id              = data.aws_subnet.glue_connection_private_subnet.id
  }
}
