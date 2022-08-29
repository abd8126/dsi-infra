# Private subnet for glue connection
data "aws_subnet" "glue_connection_private_subnet" {
  id = module.vpc.private_subnet_ids[0]
}

# VPC where the glue connection will run in. This is to retrieve the default open egress security group
data "aws_security_group" "vpc_default_security_group" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}


# Glue connection resource to run a job within a private subnet
resource "aws_glue_connection" "private_subnet" {
  name            = "private-subnet"
  connection_type = "NETWORK"

  physical_connection_requirements {
    availability_zone      = data.aws_subnet.glue_connection_private_subnet.availability_zone
    security_group_id_list = [data.aws_security_group.vpc_default_security_group.id]
    subnet_id              = data.aws_subnet.glue_connection_private_subnet.id
  }
}
