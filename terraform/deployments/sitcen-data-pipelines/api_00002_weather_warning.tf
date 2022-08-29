resource "aws_glue_catalog_table" "api_00002_weather_warning_landing" {
  name          = "api_00002_weather_warning"
  database_name = data.terraform_remote_state.base.outputs.landing_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
    "typeOfData"     = "file"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/weather-warning-api2"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        "paths" = "items,limit,offset,totalItems"
      }
    }

    columns {
      name = "type"
      type = "string"
    }
    columns {
      name = "features"
      type = "array<struct<type:string,properties:struct<issuedDate:string,weatherType:array<string>,warningLikelihood:int,warningUpdateDescription:string,warningLevel:string,warningStatus:string,warningHeadline:string,whatToExpect:array<string>,warningId:string,warningVersion:string,warningFurtherDetails:string,modifiedDate:string,validFromDate:string,affectedAreas:array<struct<regionName:string,regionCode:string,subRegions:array<string>>>,warningImpact:int,validToDate:string>,geometry:array<struct<type:string,coordinates:string>>>>"
    }
  }
}

resource "aws_s3_bucket_object" "api_00002_weather_warning_extract_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/api_00002_weather_warning_extract.py"
  source = "${path.module}/scripts/api_00002_weather_warning_extract.py"
  etag   = filemd5("${path.module}/scripts/api_00002_weather_warning_extract.py")
}

resource "aws_glue_job" "api_00002_weather_warning_extract" {
  name         = "api_00002_weather_warning_extract"
  description  = "Pulls data from the api_00002_weather_warning (API 6) endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"
  #connections  = [data.terraform_remote_state.base.outputs.glue_private_subnet_connection_id]

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.api_00002_weather_warning_extract_script.bucket}/${aws_s3_bucket_object.api_00002_weather_warning_extract_script.key}"
  }

  default_arguments = {
    "--SECRET_ID"                = "DSI/api_0002"
    "--LANDING_BUCKET"           = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--TempDir"                  = data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name
    "--enable-metrics"           = ""
    "--LANDING_DATABASE"         = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--REPOSITORY_BUCKET"        = data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name
    "--DATA_REPOSITORY_DATABASE" = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"               = aws_glue_catalog_table.api_00002_weather_warning_data_repository.name
  }
}

resource "aws_glue_catalog_table" "api_00002_weather_warning_data_repository" {
  name          = aws_glue_catalog_table.api_00002_weather_warning_landing.name
  database_name = data.terraform_remote_state.base.outputs.data_repository_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
    "typeOfData"     = "file"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/weather-warning-api2"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false

    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        "paths" = "items,limit,offset,totalItems"
      }
    }

    columns {
      name = "type"
      type = "string"
    }
    columns {
      name = "features"
      type = "array<struct<type:string,properties:struct<issuedDate:string,weatherType:array<string>,warningLikelihood:int,warningUpdateDescription:string,warningLevel:string,warningStatus:string,warningHeadline:string,whatToExpect:array<string>,warningId:string,warningVersion:string,warningFurtherDetails:string,modifiedDate:string,validFromDate:string,affectedAreas:array<struct<regionName:string,regionCode:string,subRegions:array<string>>>,warningImpact:int,validToDate:string>,geometry:array<struct<type:string,coordinates:string>>>>"
    }
  }
}

resource "aws_s3_bucket_object" "api_00002_weather_warning_transform_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/api_00002_weather_warning_transform.py"
  source = "${path.module}/scripts/api_00002_weather_warning_transform.py"
  etag   = filemd5("${path.module}/scripts/api_00002_weather_warning_transform.py")
}

resource "aws_glue_job" "api_00002_weather_warning_transform" {
  name              = "api_00002_weather_warning_transform"
  description       = "Retrieves api_00002_weather_warning data from the landing bucket and outputs new data to the data repository bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.api_00002_weather_warning_transform_script.bucket}/${aws_s3_bucket_object.api_00002_weather_warning_transform_script.key}"
  }



  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.api_00002_weather_warning_data_repository.name
    "--LANDING_BUCKET"                   = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--REPOSITORY_BUCKET"                = data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name
    "--TempDir"                          = "s3://${data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name}"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--extra-py-files"                   = "s3://${data.terraform_remote_state.base.outputs.python_libraries_bucket_name}/${aws_s3_bucket_object.transform-python-libraries[0].key},s3://${data.terraform_remote_state.base.outputs.python_libraries_bucket_name}/${aws_s3_bucket_object.transform-python-libraries[1].key},s3://${data.terraform_remote_state.base.outputs.python_libraries_bucket_name}/${aws_s3_bucket_object.transform-python-libraries[2].key}"
    "--job-language"                     = "python"
  }
}


resource "aws_glue_workflow" "api_00002_weather_warning" {
  name = "api_00002_weather_warning"
}

resource "aws_glue_trigger" "api_00002_weather_warning_extract" {
  name          = "api_00002_weather_warning_extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.api_00002_weather_warning.name

  actions {
    job_name = aws_glue_job.api_00002_weather_warning_extract.name
  }
}

resource "aws_glue_trigger" "api_00002_weather_warning_transform" {
  name          = "api_00002_weather_warning_transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.api_00002_weather_warning.name

  actions {
    job_name = aws_glue_job.api_00002_weather_warning_transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.api_00002_weather_warning_extract.name
      state    = "SUCCEEDED"
    }
  }
}