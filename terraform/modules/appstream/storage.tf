
resource "aws_s3_bucket" "appstream" {
  bucket_prefix = "appstream-shared-${terraform.workspace}"
  acl           = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    tenant = "sitcen"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_appstream_bucket" {
  bucket = aws_s3_bucket.appstream.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

