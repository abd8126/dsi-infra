output "fleet_name" {
  value = aws_appstream_fleet.qgis.name
}

output "security_group_id" {
  value = aws_security_group.appstream.id
}

output "shared_bucket_name" {
  value = aws_s3_bucket.appstream.id
}
