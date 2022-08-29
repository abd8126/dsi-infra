output "vpc_id" {
  value     = aws_vpc.vpc.id
  sensitive = true
}

output "private_subnet_ids" {
  value     = aws_subnet.private.*.id
  sensitive = true
}

output "public_subnet_ids" {
  value     = aws_subnet.public.*.id
  sensitive = true
}
