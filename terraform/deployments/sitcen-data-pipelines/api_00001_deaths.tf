resource "aws_glue_catalog_table" "api_00001_deaths_landing" {
  name          = "api_00001_deaths"
  database_name = data.terraform_remote_state.base.outputs.landing_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = 1
    "columnsOrdered"         = true
    "areColumnsQuoted"       = true
    "delimiter"              = ","
    "classification"         = "csv"
    "typeOfData"             = "file"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/deaths-api1"
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
      name = "organisation_code"
      type = "string"
    }
    columns {
      name = "organisation_name"
      type = "string"
    }
    columns {
      name = "provider_type"
      type = "string"
    }
    columns {
      name = "high_level_health_geography"
      type = "string"
    }
    columns {
      name = "stp_code"
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
    columns {
      name = "local_authority_id"
      type = "string"
    }
    columns {
      name = "local_authority_name"
      type = "string"
    }
    columns {
      name = "latitude"
      type = "decimal"
    }
    columns {
      name = "longitude"
      type = "decimal"
    }
    columns {
      name = "postcode"
      type = "string"
    }
    columns {
      name = "date"
      type = "date"
    }
    columns {
      name = "new_deaths"
      type = "int"
    }
    columns {
      name = "new_deaths_0_to_19"
      type = "int"
    }
    columns {
      name = "new_deaths_20_to_39"
      type = "int"
    }
    columns {
      name = "new_deaths_40_to_59"
      type = "int"
    }
    columns {
      name = "new_deaths_60_to_79"
      type = "int"
    }
    columns {
      name = "new_deaths_80+"
      type = "int"
    }
    columns {
      name = "new_deaths_asthma"
      type = "int"
    }
    columns {
      name = "new_deaths_chronic_kidney_disease"
      type = "int"
    }
    columns {
      name = "new_deaths_chronic_neurological_disorder"
      type = "int"
    }
    columns {
      name = "new_deaths_chronic_pulmonary_disease"
      type = "int"
    }
    columns {
      name = "new_deaths_dementia"
      type = "int"
    }
    columns {
      name = "new_deaths_diabetes"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_african"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_asian_other"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_bangladeshi"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_black_other"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_british"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_caribbean"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_chinese"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_indian"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_irish"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_mixed_other"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_other"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_pakistani"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_white_and_asian"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_white_and_black_african"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_white_and_black_caribbean"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_white_other"
      type = "int"
    }
    columns {
      name = "new_deaths_gender_female"
      type = "int"
    }
    columns {
      name = "new_deaths_gender_male"
      type = "int"
    }
    columns {
      name = "new_deaths_ischaemic_heart_disease"
      type = "int"
    }
    columns {
      name = "new_deaths_obesity"
      type = "int"
    }
    columns {
      name = "new_deaths_other_condition"
      type = "int"
    }
    columns {
      name = "new_deaths_rheumatological_disorder"
      type = "int"
    }
  }
}

resource "aws_s3_bucket_object" "api_00001_deaths_extract_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/api_00001_deaths_extract.py"
  source = "${path.module}/scripts/api_00001_deaths_extract.py"
  etag   = filemd5("${path.module}/scripts/api_00001_deaths_extract.py")
}

resource "aws_glue_job" "api_00001_deaths_extract" {
  name         = "api_00001_deaths_extract"
  description  = "Pulls data from the api_00001_deaths endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.api_00001_deaths_extract_script.bucket}/${aws_s3_bucket_object.api_00001_deaths_extract_script.key}"
  }

  default_arguments = {
    "--SECRET_ID"      = "DSI/api_00001_deaths"
    "--LANDING_BUCKET" = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--TempDir"        = data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name
    "--enable-metrics" = ""
  }
}

resource "aws_glue_catalog_table" "api_00001_deaths_data_repository" {
  name          = aws_glue_catalog_table.api_00001_deaths_landing.name
  database_name = data.terraform_remote_state.base.outputs.data_repository_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = 1
    "columnsOrdered"         = true
    "areColumnsQuoted"       = true
    "delimiter"              = ","
    "classification"         = "csv"
    "typeOfData"             = "file"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/deaths-api1"
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
      name = "date"
      type = "date"
    }
    columns {
      name = "new_deaths_ethnicity_other"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_white_other"
      type = "int"
    }
    columns {
      name = "nhs_region_name"
      type = "string"
    }
    columns {
      name = "new_deaths_ethnicity_white_and_black_caribbean"
      type = "int"
    }
    columns {
      name = "new_deaths_dementia"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_asian_other"
      type = "int"
    }
    columns {
      name = "local_authority_id"
      type = "string"
    }
    columns {
      name = "new_deaths_80+"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_chinese"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_irish"
      type = "int"
    }
    columns {
      name = "local_authority_name"
      type = "string"
    }
    columns {
      name = "new_deaths_ethnicity_white_and_black_african"
      type = "int"
    }
    columns {
      name = "nhs_region_id"
      type = "string"
    }
    columns {
      name = "new_deaths_ethnicity_caribbean"
      type = "int"
    }
    columns {
      name = "latitude"
      type = "double"
    }
    columns {
      name = "new_deaths_ethnicity_indian"
      type = "int"
    }
    columns {
      name = "new_deaths_chronic_neurological_disorder"
      type = "int"
    }
    columns {
      name = "new_deaths_60_to_79"
      type = "int"
    }
    columns {
      name = "new_deaths_0_to_19"
      type = "int"
    }
    columns {
      name = "organisation_code"
      type = "string"
    }
    columns {
      name = "organisation_name"
      type = "string"
    }
    columns {
      name = "provider_type"
      type = "string"
    }
    columns {
      name = "stp_code"
      type = "string"
    }
    columns {
      name = "new_deaths_ethnicity_mixed_other"
      type = "int"
    }
    columns {
      name = "new_deaths_asthma"
      type = "int"
    }
    columns {
      name = "new_deaths_rheumatological_disorder"
      type = "int"
    }
    columns {
      name = "new_deaths_40_to_59"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_white_and_asian"
      type = "int"
    }
    columns {
      name = "new_deaths_ischaemic_heart_disease"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_pakistani"
      type = "int"
    }
    columns {
      name = "new_deaths_chronic_kidney_disease"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_african"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_black_other"
      type = "int"
    }
    columns {
      name = "longitude"
      type = "double"
    }
    columns {
      name = "new_deaths_other_condition"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_bangladeshi"
      type = "int"
    }
    columns {
      name = "new_deaths_20_to_39"
      type = "int"
    }
    columns {
      name = "postcode"
      type = "string"
    }
    columns {
      name = "new_deaths_gender_female"
      type = "int"
    }
    columns {
      name = "new_deaths_ethnicity_british"
      type = "int"
    }
    columns {
      name = "new_deaths"
      type = "int"
    }
    columns {
      name = "new_deaths_diabetes"
      type = "int"
    }
    columns {
      name = "new_deaths_gender_male"
      type = "int"
    }
    columns {
      name = "new_deaths_obesity"
      type = "int"
    }
    columns {
      name = "new_deaths_chronic_pulmonary_disease"
      type = "int"
    }
    columns {
      name = "high_level_health_geography"
      type = "string"
    }

  }
}

resource "aws_s3_bucket_object" "api_00001_deaths_transform_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/api_00001_deaths_transform.py"
  source = "${path.module}/scripts/api_00001_deaths_transform.py"
  etag   = filemd5("${path.module}/scripts/api_00001_deaths_transform.py")
}

resource "aws_glue_job" "api_00001_deaths_transform" {
  name              = "api_00001_deaths_transform"
  description       = "Retrieves api_00001_deaths data from the landing bucket, transforms and outputs new data to the landing bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.api_00001_deaths_transform_script.bucket}/${aws_s3_bucket_object.api_00001_deaths_transform_script.key}"
  }



  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.api_00001_deaths_data_repository.name
    "--TempDir"                          = "s3://${data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name}"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }
}


resource "aws_glue_workflow" "api_00001_deaths" {
  name = "api_00001_deaths"
}

resource "aws_glue_trigger" "api_00001_deaths_extract" {
  name          = "api_00001_deaths-extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.api_00001_deaths.name

  actions {
    job_name = aws_glue_job.api_00001_deaths_extract.name
  }
}

resource "aws_glue_trigger" "api_00001_deaths_transform" {
  name          = "api_00001_deaths-transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.api_00001_deaths.name

  actions {
    job_name = aws_glue_job.api_00001_deaths_transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.api_00001_deaths_extract.name
      state    = "SUCCEEDED"
    }
  }
}
