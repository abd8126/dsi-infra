output "tenant_landing_bucket_name" {
   value = resource.aws_s3_bucket.landing_bucket_tenant.id
}
output "tenant_repository_bucket_name" {
   value = resource.aws_s3_bucket.bucket_tenant.id
}