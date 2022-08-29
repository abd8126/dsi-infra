resource "aws_s3_bucket" "pipeline_scripts" {
  bucket_prefix = "data-pipeline-scripts-${terraform.workspace}-"

}
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.pipeline_scripts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-config" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioning]

  bucket = aws_s3_bucket.pipeline_scripts.bucket

  rule {
    id = "config9"


    noncurrent_version_expiration {
      noncurrent_days = var.noncurrentdelete
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_scripts" {
  bucket = aws_s3_bucket.pipeline_scripts.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}





resource "aws_s3_bucket_public_access_block" "pipeline_scripts" {
  bucket = aws_s3_bucket.pipeline_scripts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "glue_temp_dir" {
  bucket_prefix = "glue-temp-dir-${terraform.workspace}-"

}


resource "aws_s3_bucket_versioning" "versioningglue_temp" {
  bucket = aws_s3_bucket.glue_temp_dir.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-configglue_temp" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioningglue_temp]

  bucket = aws_s3_bucket.glue_temp_dir.bucket

  rule {
    id = "config2"


    noncurrent_version_expiration {
      noncurrent_days = var.noncurrentdelete
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "glue_temp" {
  bucket = aws_s3_bucket.glue_temp_dir.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}



resource "aws_s3_bucket_public_access_block" "glue_temp_dir" {
  bucket = aws_s3_bucket.glue_temp_dir.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "data_landing" {
  bucket_prefix = "data-landing-${terraform.workspace}-"

}


resource "aws_s3_bucket_versioning" "versioningdata_landing" {
  bucket = aws_s3_bucket.data_landing.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-configdata_landing" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioningdata_landing]

  bucket = aws_s3_bucket.data_landing.bucket

  rule {
    id = "config3"


    noncurrent_version_expiration {
      noncurrent_days = var.noncurrentdelete
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_landing" {
  bucket = aws_s3_bucket.data_landing.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}




resource "aws_s3_bucket_public_access_block" "data_landing" {
  bucket = aws_s3_bucket.data_landing.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "data_repository" {
  bucket = aws_s3_bucket.data_repository.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "python_libraries" {
  bucket_prefix = "python-libraries-${terraform.workspace}-"

}


resource "aws_s3_bucket_versioning" "versioningpython_libraries" {
  bucket = aws_s3_bucket.python_libraries.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-configpython_libraries" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioningpython_libraries]

  bucket = aws_s3_bucket.python_libraries.bucket

  rule {
    id = "config4"


    noncurrent_version_expiration {
      noncurrent_days = var.noncurrentdelete
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "python_libraries" {
  bucket = aws_s3_bucket.python_libraries.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}



resource "aws_s3_bucket_public_access_block" "python_libraries" {
  bucket = aws_s3_bucket.python_libraries.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_glue_catalog_database" "landing" {
  name = "dsi-landing"
}

resource "aws_glue_catalog_database" "data_repository" {
  name = "dsi-data-repository"
}


resource "aws_s3_bucket" "data_repository" {
  bucket_prefix = "data-repository-${terraform.workspace}-"
}

resource "aws_s3_bucket_versioning" "versioningdata_repository" {
  bucket = aws_s3_bucket.data_repository.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-configdata_repository" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.versioningdata_repository]

  bucket = aws_s3_bucket.data_repository.bucket

  rule {
    id = "config1"


    noncurrent_version_expiration {
      noncurrent_days = var.noncurrentdelete
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_repository" {
  bucket = aws_s3_bucket.data_repository.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

