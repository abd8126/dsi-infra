resource "aws_s3_bucket" "bucket_tenant" {
  bucket = "all-${terraform.workspace}-tenant-bucket"
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.bucket_tenant.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_public" {
  bucket = aws_s3_bucket.bucket_tenant.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "folder1" {
    count  = length(var.tenant)
    bucket = aws_s3_bucket.bucket_tenant.id
    acl    = "private"
    key    = "${var.tenant[count.index]}/repository/"
}

resource "aws_s3_bucket_object" "folder1_1" {
    count  = length(var.tenant)
    bucket = aws_s3_bucket.bucket_tenant.id
    acl    = "private"
    key    = "${var.tenant[count.index]}/temp/"
}

resource "aws_s3_bucket" "landing_bucket_tenant" {
  bucket = "all-${terraform.workspace}-tenant-landing-bucket"
}

resource "aws_s3_bucket_acl" "s3_landing_acl" {
  bucket = aws_s3_bucket.landing_bucket_tenant.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "s3_landing_public" {
  bucket = aws_s3_bucket.landing_bucket_tenant.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "folder2" {
    count  = length(var.tenant)
    bucket = aws_s3_bucket.landing_bucket_tenant.id
    acl    = "private"
    key    = "${var.tenant[count.index]}/"
}

#create s3 bucket for ETL code storage

resource "aws_s3_bucket" "glue_bucket" {
  bucket = "all-${terraform.workspace}-tenant-scripts-bucket"

}

resource "aws_s3_bucket_acl" "glue_s3_acl" {
  bucket = aws_s3_bucket.glue_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "glue_s3_public" {
  bucket = aws_s3_bucket.glue_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "tenant_folder" {
    bucket = aws_s3_bucket.glue_bucket.id
    acl    = "private"
    key    = "blueprints/"
}
resource "aws_s3_bucket_object" "tenant_folder1" {
    count  = length(var.tenant)
    bucket = aws_s3_bucket.glue_bucket.id
    acl    = "private"
    key    = "${var.tenant[count.index]}/"
}

#create s3 bucket all-tenants-pre-landing-bucket
resource "aws_s3_bucket" "prelanding_bucket" {
  bucket = "all-${terraform.workspace}-tenant-pre-landing-bucket"

}

resource "aws_s3_bucket_acl" "prelanding_s3_acl" {
  bucket = aws_s3_bucket.prelanding_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "prelanding_s3_public" {
  bucket = aws_s3_bucket.prelanding_bucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_object" "tenant_folder2" {
    count  = length(var.tenant)
    bucket = aws_s3_bucket.prelanding_bucket.id
    acl    = "private"
    key    = "${var.tenant[count.index]}/"
}