resource "aws_glue_catalog_table" "met-office-flood-guidance-landing" {
  name          = "met_office_flood_guidance"
  database_name = data.terraform_remote_state.base.outputs.landing_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"       = "TRUE"
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/met-offfice-flood"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false

    ser_de_info {
      name                  = "jsonserde"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "statements"
      type = "array<struct<id:string,issued_at:string,pdf_url:string,detailed_csv_url:string,area_of_concert_url:string,flood_risk_trend:struct<day1:string,day2:string,day3:string,day4:string,day5:string>,sources:array<string>,headline:string,amendments:string,future_forecast:string,last_modified_at:string,next_issue_due_at:string,png_thumbnails_with_days_url:string,risk_areas:array<struct<id:int,statement_id:int,updated_at:string,beyond_five_days:boolean,ordering:int,risk_area_blocks:array<struct<id:int,days:array<int>,risk_area_id:int,risk_levels:struct<river:array<int>,surface:array<int>,ground:array<int>,coastal:array<int>>,additional_information:string,polys:array<struct<id:int,coordinates:array<array<array<double>>>,area:double,label_position:array<double>,poly_type:string,risk_area_block_id:int,counties:array<struct<name:string>>>>>>>>,aoc_maps:array<struct<id:int,title:string,ordering:int,caption:string,ratio:array<string>,statement_id:int,polys:array<struct<coordinates:array<array<array<double>>>,area:double,label_position:array<double>,poly_type:string,risk_area_block_id:int,counties:array<struct<name:string>>>>>>,public_forecast:struct<id:int,english_forecast:string,welsh_forecast:string,england_forecast:string,wales_forecast_english:string,wales_forecast_welsh:string,published_at:string>>>"
    }
  }
}

resource "aws_s3_bucket_object" "met-office-flood-guidance-extract-script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/met-office-flood-guidance-import.py"
  source = "${path.module}/scripts/met-office-flood-guidance-import.py"
  etag   = filemd5("${path.module}/scripts/met-office-flood-guidance-import.py")
}

resource "aws_glue_job" "met-office-flood-guidance-extract" {
  name         = "met-office-flood-guidance-extract"
  description  = "Pulls data from the met-office-flood-guidance endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.met-office-flood-guidance-extract-script.bucket}/${aws_s3_bucket_object.met-office-flood-guidance-extract-script.key}"
  }

  default_arguments = {
    "--SECRET_ID"                = "DSI/api_3"
    "--LANDING_BUCKET"           = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--TempDir"                  = data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name
    "--enable-metrics"           = ""
    "--LANDING_DATABASE"         = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--REPOSITORY_BUCKET"        = data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name
    "--DATA_REPOSITORY_DATABASE" = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"               = aws_glue_catalog_table.met-office-flood-guidance-data-repository.name
  }
}

resource "aws_glue_catalog_table" "met-office-flood-guidance-data-repository" {
  name          = aws_glue_catalog_table.met-office-flood-guidance-landing.name
  database_name = data.terraform_remote_state.base.outputs.data_repository_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"       = "TRUE"
    "classification" = "json"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/met-offfice-flood"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false

    ser_de_info {
      name                  = "jsonserde"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }

    columns {
      name = "statements"
      type = "array<struct<id:string,issued_at:string,pdf_url:string,detailed_csv_url:string,area_of_concert_url:string,flood_risk_trend:struct<day1:string,day2:string,day3:string,day4:string,day5:string>,sources:array<string>,headline:string,amendments:string,future_forecast:string,last_modified_at:string,next_issue_due_at:string,png_thumbnails_with_days_url:string,risk_areas:array<struct<id:int,statement_id:int,updated_at:string,beyond_five_days:boolean,ordering:int,risk_area_blocks:array<struct<id:int,days:array<int>,risk_area_id:int,risk_levels:struct<river:array<int>,surface:array<int>,ground:array<int>,coastal:array<int>>,additional_information:string,polys:array<struct<id:int,coordinates:array<array<array<double>>>,area:double,label_position:array<double>,poly_type:string,risk_area_block_id:int,counties:array<struct<name:string>>>>>>>>,aoc_maps:array<struct<id:int,title:string,ordering:int,caption:string,ratio:array<string>,statement_id:int,polys:array<struct<coordinates:array<array<array<double>>>,area:double,label_position:array<double>,poly_type:string,risk_area_block_id:int,counties:array<struct<name:string>>>>>>,public_forecast:struct<id:int,english_forecast:string,welsh_forecast:string,england_forecast:string,wales_forecast_english:string,wales_forecast_welsh:string,published_at:string>>>"
    }
  }
}

resource "aws_s3_bucket_object" "met-office-flood-guidance-transform-script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/met-office-flood-guidance-transform.py"
  source = "${path.module}/scripts/met-office-flood-guidance-transform.py"
  etag   = filemd5("${path.module}/scripts/met-office-flood-guidance-transform.py")
}

resource "aws_s3_bucket_object" "transform-python-libraries" {
  count  = length(var.python_libraries_files)
  bucket = data.terraform_remote_state.base.outputs.python_libraries_bucket_name
  key    = "sitcen/python-libraries/${var.python_libraries_files[count.index]}"
  source = "${path.module}/python-libraries/${var.python_libraries_files[count.index]}"
  #etag   = filemd5("${path.module}/python-libraries/${var.python_libraries_files[count.index]}"
}

resource "aws_glue_job" "met-office-flood-guidance-transform" {
  name              = "met-office-flood-guidance-transform"
  description       = "Retrieves met-office-flood-guidance data from the landing bucket and outputs new data to the data repository bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.met-office-flood-guidance-transform-script.bucket}/${aws_s3_bucket_object.met-office-flood-guidance-transform-script.key}"
  }



  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.met-office-flood-guidance-data-repository.name
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


resource "aws_glue_workflow" "met-office-flood-guidance" {
  name = "met-office-flood-guidance"
}

resource "aws_glue_trigger" "met-office-flood-guidance-extract" {
  name          = "met-office-flood-guidance-extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.met-office-flood-guidance.name

  actions {
    job_name = aws_glue_job.met-office-flood-guidance-extract.name
  }
}

resource "aws_glue_trigger" "met-office-flood-guidance-transform" {
  name          = "met-office-flood-guidance-transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.met-office-flood-guidance.name

  actions {
    job_name = aws_glue_job.met-office-flood-guidance-transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.met-office-flood-guidance-extract.name
      state    = "SUCCEEDED"
    }
  }
}
