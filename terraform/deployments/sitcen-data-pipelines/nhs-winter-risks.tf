resource "aws_glue_catalog_table" "nhs-winter-risks-landing" {
  name          = "nhs-winter-risks"
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
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/nhs-winter-risks-api1"
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
      name = "location_type"
      type = "string"
    }

    columns {
      name = "location_name"
      type = "string"
    }

    columns {
      name = "date"
      type = "string"
    }

    columns {
      name = "metric_name"
      type = "string"
    }

    columns {
      name = "metric_value"
      type = "date"
    }

    columns {
      name = "unit"
      type = "string"
    }
  }
}

resource "aws_s3_bucket_object" "nhs-winter-risks-extract_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/nhs-winter-risks-import.py"
  source = "${path.module}/scripts/nhs-winter-risks-import.py"
  etag   = filemd5("${path.module}/scripts/nhs-winter-risks-import.py")
}

resource "aws_glue_job" "nhs-winter-risks-extract" {
  name         = "nhs-winter-risks-extract"
  description  = "Pulls data from the nhs-winter-risks endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.nhs-winter-risks-extract_script.bucket}/${aws_s3_bucket_object.nhs-winter-risks-extract_script.key}"
  }

  default_arguments = {
    "--SECRET_ID"      = "DSI/api_1_wr"
    "--LANDING_BUCKET" = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--TempDir"        = data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name
    "--enable-metrics" = ""
  }
}

resource "aws_glue_catalog_table" "nhs-winter-risks-data_repository" {
  name          = aws_glue_catalog_table.nhs-winter-risks-landing.name
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
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/nhs-winter-risks-api1"
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
      name = "location_type"
      type = "string"
    }

    columns {
      name = "location_name"
      type = "string"
    }

    columns {
      name = "date"
      type = "string"
    }

    columns {
      name = "metric_name"
      type = "string"
    }

    columns {
      name = "metric_value"
      type = "date"
    }

    columns {
      name = "unit"
      type = "string"
    }
  }
}
resource "aws_s3_bucket_object" "nhs-winter-risks-transform_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/nhs-winter-risks-transform.py"
  source = "${path.module}/scripts/nhs-winter-risks-transform.py"
  etag   = filemd5("${path.module}/scripts/nhs-winter-risks-transform.py")
}

resource "aws_glue_job" "nhs-winter-risks-transform" {
  name              = "nhs-winter-risks-transform"
  description       = "Retrieves nhs-winter-risks data from the landing bucket and outputs new data to the data repository bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.nhs-winter-risks-transform_script.bucket}/${aws_s3_bucket_object.nhs-winter-risks-transform_script.key}"
  }



  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.nhs-winter-risks-data_repository.name
    "--TempDir"                          = "s3://${data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name}"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }
}


resource "aws_glue_workflow" "nhs-winter-risks" {
  name = "nhs-winter-risks"
}

resource "aws_glue_trigger" "nhs-winter-risks-extract" {
  name          = "nhs-winter-risks-extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.nhs-winter-risks.name

  actions {
    job_name = aws_glue_job.nhs-winter-risks-extract.name
  }
}

resource "aws_glue_trigger" "nhs-winter-risks-transform" {
  name          = "nhs-winter-risks-transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.nhs-winter-risks.name

  actions {
    job_name = aws_glue_job.nhs-winter-risks-transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.nhs-winter-risks-extract.name
      state    = "SUCCEEDED"
    }
  }
}