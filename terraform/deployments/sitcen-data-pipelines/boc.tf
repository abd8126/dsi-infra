resource "aws_glue_catalog_table" "boc_landing" {
  name          = "boc"
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
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/boc-api5"
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
      name = "border_flow_indicator_id"
      type = "string"
    }

    columns {
      name = "aggregation_name"
      type = "string"
    }

    columns {
      name = "aggregation"
      type = "string"
    }

    columns {
      name = "high_impact_location_id"
      type = "string"
    }

    columns {
      name = "observation_date"
      type = "date"
    }

    columns {
      name = "inbound_freight_vehicles_number"
      type = "string"
    }

    columns {
      name = "outbound_freight_vehicles_number"
      type = "string"
    }

    columns {
      name = "inbound_passenger_vehicles_number"
      type = "string"
    }

    columns {
      name = "outbound_passenger_vehicles_number"
      type = "string"
    }

    columns {
      name = "inbound_air_passengers_number"
      type = "string"
    }

    columns {
      name = "outbound_air_passengers_number"
      type = "string"
    }

    columns {
      name = "inbound_freight_vehicles_number_rolling_avg"
      type = "string"
    }

    columns {
      name = "outbound_freight_vehicles_number_rolling_avg"
      type = "string"
    }

    columns {
      name = "inbound_passenger_vehicles_number_rolling_avg"
      type = "string"
    }

    columns {
      name = "outbound_passenger_vehicles_number_rolling_avg"
      type = "string"
    }
  }
}

resource "aws_s3_bucket_object" "boc_extract_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/boc_extract.py"
  source = "${path.module}/scripts/boc_extract.py"
  etag   = filemd5("${path.module}/scripts/boc_extract.py")
}

resource "aws_glue_job" "boc_extract" {
  name         = "boc_extract"
  description  = "Pulls data from the boc endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.boc_extract_script.bucket}/${aws_s3_bucket_object.boc_extract_script.key}"
  }

  default_arguments = {
    "--SECRET_ID"      = "DSI/api_5"
    "--LANDING_BUCKET" = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--TempDir"        = data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name
    "--enable-metrics" = ""
  }
}

resource "aws_glue_catalog_table" "boc_data_repository" {
  name          = aws_glue_catalog_table.boc_landing.name
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
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/boc-api5"
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
      name = "border_flow_indicator_id"
      type = "string"
    }

    columns {
      name = "aggregation_name"
      type = "string"
    }

    columns {
      name = "aggregation"
      type = "string"
    }

    columns {
      name = "high_impact_location_id"
      type = "string"
    }

    columns {
      name = "observation_date"
      type = "date"
    }

    columns {
      name = "inbound_freight_vehicles_number"
      type = "string"
    }

    columns {
      name = "outbound_freight_vehicles_number"
      type = "string"
    }

    columns {
      name = "inbound_passenger_vehicles_number"
      type = "string"
    }

    columns {
      name = "outbound_passenger_vehicles_number"
      type = "string"
    }

    columns {
      name = "inbound_air_passengers_number"
      type = "string"
    }

    columns {
      name = "outbound_air_passengers_number"
      type = "string"
    }

    columns {
      name = "inbound_freight_vehicles_number_rolling_avg"
      type = "string"
    }

    columns {
      name = "outbound_freight_vehicles_number_rolling_avg"
      type = "string"
    }

    columns {
      name = "inbound_passenger_vehicles_number_rolling_avg"
      type = "string"
    }

    columns {
      name = "outbound_passenger_vehicles_number_rolling_avg"
      type = "string"
    }
  }
}

resource "aws_s3_bucket_object" "boc_transform_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/boc_transform.py"
  source = "${path.module}/scripts/boc_transform.py"
  etag   = filemd5("${path.module}/scripts/boc_transform.py")
}

resource "aws_glue_job" "boc_transform" {
  name              = "boc_transform"
  description       = "Retrieves boc data from the landing bucket, transforms and outputs new data to the landing bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.boc_transform_script.bucket}/${aws_s3_bucket_object.boc_transform_script.key}"
  }



  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.boc_data_repository.name
    "--TempDir"                          = "s3://${data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name}"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }
}


resource "aws_glue_workflow" "boc" {
  name = "boc"
}

resource "aws_glue_trigger" "boc_extract" {
  name          = "boc-extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.boc.name

  actions {
    job_name = aws_glue_job.boc_extract.name
  }
}

resource "aws_glue_trigger" "boc_transform" {
  name          = "boc-transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.boc.name

  actions {
    job_name = aws_glue_job.boc_transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.boc_extract.name
      state    = "SUCCEEDED"
    }
  }
}
