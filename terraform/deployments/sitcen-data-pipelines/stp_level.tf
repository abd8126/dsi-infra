resource "aws_glue_catalog_table" "api_00001_stp_level_landing" {
  name          = "api_00001_stp_level"
  database_name = data.terraform_remote_state.base.outputs.landing_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = 1
    "columnsOrdered"         = true
    "areColumnsQuoted"       = false
    "delimiter"              = ","
    "classification"         = "csv"
    "typeOfData"             = "file"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/stp-level-api1"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim" = ","
      }
    }

    columns {
      name = "stp_code"
      type = "string"
    }

    columns {
      name = "date"
      type = "string"
    }

    columns {
      name = "confirmed_covid_discharges"
      type = "double"
    }

    columns {
      name = "emergency_admissions_a&es"
      type = "double"
    }

    columns {
      name = "stp_name"
      type = "string"
    }

    columns {
      name = "nhs_region_id"
      type = "string"
    }

    columns {
      name = "nhs_region_name"
      type = "string"
    }
  }
}

resource "aws_s3_bucket_object" "api_00001_stp_level_extract_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/api_00001_stp_level_extract.py"
  source = "${path.module}/scripts/api_00001_stp_level_extract.py"
  etag   = filemd5("${path.module}/scripts/api_00001_stp_level_extract.py")
}

resource "aws_glue_job" "api_00001_stp_level_extract" {
  name         = "api_00001_stp_level_extract"
  description  = "Pulls data from the api_00001_stp_level endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.api_00001_stp_level_extract_script.bucket}/${aws_s3_bucket_object.api_00001_stp_level_extract_script.key}"
  }

  default_arguments = {
    "--SECRET_ID"      = "DSI/api_1"
    "--LANDING_BUCKET" = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--TempDir"        = data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name
    "--enable-metrics" = ""
  }
}

resource "aws_glue_catalog_table" "api_00001_stp_level_data_repository" {
  name          = aws_glue_catalog_table.api_00001_stp_level_landing.name
  database_name = data.terraform_remote_state.base.outputs.data_repository_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = 1
    "columnsOrdered"         = true
    "areColumnsQuoted"       = false
    "delimiter"              = ","
    "classification"         = "csv"
    "typeOfData"             = "file"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/stp-level-api1"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim" = ","
      }
    }

    columns {
      name = "stp_code"
      type = "string"
    }

    columns {
      name = "date"
      type = "string"
    }

    columns {
      name = "confirmed_covid_discharges"
      type = "double"
    }

    columns {
      name = "emergency_admissions_a&es"
      type = "double"
    }

    columns {
      name = "stp_name"
      type = "string"
    }

    columns {
      name = "nhs_region_id"
      type = "string"
    }

    columns {
      name = "nhs_region_name"
      type = "string"
    }
  }
}

resource "aws_s3_bucket_object" "api_00001_stp_level_transform_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/api_00001_stp_level_transform.py"
  source = "${path.module}/scripts/api_00001_stp_level_transform.py"
  etag   = filemd5("${path.module}/scripts/api_00001_stp_level_transform.py")
}

resource "aws_glue_job" "api_00001_stp_level_transform" {
  name              = "api_00001_stp_level_transform"
  description       = "Retrieves api_00001_stp_level data from the landing bucket, transforms and outputs new data to the landing bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.api_00001_stp_level_transform_script.bucket}/${aws_s3_bucket_object.api_00001_stp_level_transform_script.key}"
  }



  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.api_00001_stp_level_data_repository.name
    "--TempDir"                          = "s3://${data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name}"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }
}


resource "aws_glue_workflow" "api_00001_stp_level" {
  name = "api_00001_stp_level"
}

resource "aws_glue_trigger" "api_00001_stp_level_extract" {
  name          = "api_00001_stp_level-extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.api_00001_stp_level.name

  actions {
    job_name = aws_glue_job.api_00001_stp_level_extract.name
  }
}

resource "aws_glue_trigger" "api_00001_stp_level_transform" {
  name          = "api_00001_stp_level-transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.api_00001_stp_level.name

  actions {
    job_name = aws_glue_job.api_00001_stp_level_transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.api_00001_stp_level_extract.name
      state    = "SUCCEEDED"
    }
  }
}