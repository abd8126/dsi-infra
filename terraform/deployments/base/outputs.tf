output "vpc_id" {
  value     = module.vpc.vpc_id
  sensitive = true
}


output "private_subnet_ids" {
  value     = module.vpc.private_subnet_ids
  sensitive = true
}

output "public_subnet_ids" {
  value     = module.vpc.public_subnet_ids
  sensitive = true
}

output "data_pipeline_scripts_bucket_name" {
  value = aws_s3_bucket.pipeline_scripts.id
}

output "glue_temp_dir_bucket_name" {
  value = aws_s3_bucket.glue_temp_dir.id
}

output "data_landing_bucket_name" {
  value = aws_s3_bucket.data_landing.id
}

output "data_repository_bucket_name" {
  value = aws_s3_bucket.data_repository.id
}

output "python_libraries_bucket_name" {
  value = aws_s3_bucket.python_libraries.id
}

output "landing_glue_database_name" {
  value = aws_glue_catalog_database.landing.name
}

output "data_repository_glue_database_name" {
  value = aws_glue_catalog_database.data_repository.name
}

output "glue_private_subnet_connection_id" {
  value = aws_glue_connection.private_subnet.name
}
