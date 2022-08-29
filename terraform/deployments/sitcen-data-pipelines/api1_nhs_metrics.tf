resource "aws_glue_catalog_table" "api1_nhs_metrics_landing" {
  name          = "api1_nhs_metrics"
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
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/nhs-metrics-api1"
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
      name = "estimated_admissions_automated_0_5"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_6_17"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_18_64"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_65_84"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_85_plus"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_total"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_unknown"
      type = "double"
    }

    columns {
      name = "covid_patients_unknown"
      type = "double"
    }

    columns {
      name = "covid_patients_total"
      type = "double"
    }

    columns {
      name = "covid_patients_0_5"
      type = "double"
    }

    columns {
      name = "covid_patients_6_17"
      type = "double"
    }

    columns {
      name = "covid_patients_18_24"
      type = "double"
    }

    columns {
      name = "covid_patients_25_34"
      type = "double"
    }

    columns {
      name = "covid_patients_35_44"
      type = "double"
    }

    columns {
      name = "covid_patients_45_54"
      type = "double"
    }

    columns {
      name = "covid_patients_55_64"
      type = "double"
    }

    columns {
      name = "covid_patients_65_74"
      type = "double"
    }

    columns {
      name = "covid_patients_75_84"
      type = "double"
    }

    columns {
      name = "covid_patients_85_plus"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_unknown"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_total"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_0_5"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_6_17"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_18_24"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_25_34"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_35_44"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_45_54"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_55_64"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_65_74"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_75_84"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_85_plus"
      type = "double"
    }

    columns {
      name = "date"
      type = "string"
    }

    columns {
      name = "region"
      type = "string"
    }

    columns {
      name = "source"
      type = "string"
    }

    columns {
      name = "o_covid"
      type = "double"
    }

    columns {
      name = "o_non_covid"
      type = "double"
    }

    columns {
      name = "o_unoccupied"
      type = "double"
    }

    columns {
      name = "o_plus_covid"
      type = "double"
    }

    columns {
      name = "o_plus_non_covid"
      type = "double"
    }

    columns {
      name = "o_plus_unoccupied"
      type = "double"
    }

    columns {
      name = "v_covid"
      type = "double"
    }

    columns {
      name = "v_non_covid"
      type = "double"
    }

    columns {
      name = "v_unoccupied"
      type = "double"
    }

    columns {
      name = "discharges"
      type = "double"
    }

    columns {
      name = "admissions"
      type = "double"
    }

    columns {
      name = "diagnosed"
      type = "double"
    }

    columns {
      name = "deaths"
      type = "double"
    }

    columns {
      name = "deaths_0_to_19"
      type = "double"
    }

    columns {
      name = "deaths_20_to_39"
      type = "double"
    }

    columns {
      name = "deaths_40_to_59"
      type = "double"
    }

    columns {
      name = "deaths_60_to_79"
      type = "double"
    }

    columns {
      name = "deaths_80"
      type = "double"
    }

    columns {
      name = "total_patients_in_ac_type_one"
      type = "double"
    }

    columns {
      name = "covid_patients_in_ac_type_one"
      type = "double"
    }

    columns {
      name = "hdu_itu_covid"
      type = "double"
    }

    columns {
      name = "estimated_admissions"
      type = "string"
    }

    columns {
      name = "deaths_nhs_staff_verified"
      type = "double"
    }

    columns {
      name = "deaths_nhs_staff_awaiting"
      type = "double"
    }

    columns {
      name = "all_beds_covid_positive"
      type = "double"
    }

    columns {
      name = "hdu_itu_non_covid"
      type = "double"
    }

    columns {
      name = "hdu_itu_unoccupied"
      type = "double"
    }

    columns {
      name = "ga_covid"
      type = "double"
    }

    columns {
      name = "ga_unoccupied"
      type = "double"
    }

    columns {
      name = "ga_non_covid"
      type = "double"
    }

    columns {
      name = "absent_doctors_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_doctors_covid_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_nurses_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_nurses_covid_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_covid_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_total_ac_type_one"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated"
      type = "double"
    }

    columns {
      name = "new_community_admissions"
      type = "double"
    }

    columns {
      name = "new_community_admissions_7_lag"
      type = "double"
    }

    columns {
      name = "new_cases"
      type = "double"
    }

    columns {
      name = "estimated_admissions_care_home"
      type = "double"
    }

    columns {
      name = "f_date"
      type = "string"
    }

  }
}

resource "aws_s3_bucket_object" "api1_nhs_metrics_extract_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/api1_nhs_metrics_extract.py"
  source = "${path.module}/scripts/api1_nhs_metrics_extract.py"
  etag   = filemd5("${path.module}/scripts/api1_nhs_metrics_extract.py")
}

resource "aws_glue_job" "api1_nhs_metrics_extract" {
  name         = "api1_nhs_metrics_extract"
  description  = "Pulls data from the API1 metrics endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.api1_nhs_metrics_extract_script.bucket}/${aws_s3_bucket_object.api1_nhs_metrics_extract_script.key}"
  }

  default_arguments = {
    "--SECRET_ID"      = "DSI/API00001_nhs_metrics"
    "--LANDING_BUCKET" = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--TempDir"        = "s3://${data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name}"
    "--enable-metrics" = ""
  }
}

resource "aws_glue_catalog_table" "api1_nhs_metrics_data_repository" {
  name          = aws_glue_catalog_table.api1_nhs_metrics_landing.name
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
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/nhs-metrics-api1"
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
      name = "estimated_admissions_automated_0_5"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_6_17"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_18_64"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_65_84"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_85_plus"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_total"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated_unknown"
      type = "double"
    }

    columns {
      name = "covid_patients_unknown"
      type = "double"
    }

    columns {
      name = "covid_patients_total"
      type = "double"
    }

    columns {
      name = "covid_patients_0_5"
      type = "double"
    }

    columns {
      name = "covid_patients_6_17"
      type = "double"
    }

    columns {
      name = "covid_patients_18_24"
      type = "double"
    }

    columns {
      name = "covid_patients_25_34"
      type = "double"
    }

    columns {
      name = "covid_patients_35_44"
      type = "double"
    }

    columns {
      name = "covid_patients_45_54"
      type = "double"
    }

    columns {
      name = "covid_patients_55_64"
      type = "double"
    }

    columns {
      name = "covid_patients_65_74"
      type = "double"
    }

    columns {
      name = "covid_patients_75_84"
      type = "double"
    }

    columns {
      name = "covid_patients_85_plus"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_unknown"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_total"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_0_5"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_6_17"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_18_24"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_25_34"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_35_44"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_45_54"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_55_64"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_65_74"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_75_84"
      type = "double"
    }

    columns {
      name = "mv_covid_patients_85_plus"
      type = "double"
    }

    columns {
      name = "date"
      type = "string"
    }

    columns {
      name = "region"
      type = "string"
    }

    columns {
      name = "source"
      type = "string"
    }

    columns {
      name = "o_covid"
      type = "double"
    }

    columns {
      name = "o_non_covid"
      type = "double"
    }

    columns {
      name = "o_unoccupied"
      type = "double"
    }

    columns {
      name = "o_plus_covid"
      type = "double"
    }

    columns {
      name = "o_plus_non_covid"
      type = "double"
    }

    columns {
      name = "o_plus_unoccupied"
      type = "double"
    }

    columns {
      name = "v_covid"
      type = "double"
    }

    columns {
      name = "v_non_covid"
      type = "double"
    }

    columns {
      name = "v_unoccupied"
      type = "double"
    }

    columns {
      name = "discharges"
      type = "double"
    }

    columns {
      name = "admissions"
      type = "double"
    }

    columns {
      name = "diagnosed"
      type = "double"
    }

    columns {
      name = "deaths"
      type = "double"
    }

    columns {
      name = "deaths_0_to_19"
      type = "double"
    }

    columns {
      name = "deaths_20_to_39"
      type = "double"
    }

    columns {
      name = "deaths_40_to_59"
      type = "double"
    }

    columns {
      name = "deaths_60_to_79"
      type = "double"
    }

    columns {
      name = "deaths_80"
      type = "double"
    }

    columns {
      name = "total_patients_in_ac_type_one"
      type = "double"
    }

    columns {
      name = "covid_patients_in_ac_type_one"
      type = "double"
    }

    columns {
      name = "hdu_itu_covid"
      type = "double"
    }

    columns {
      name = "estimated_admissions"
      type = "string"
    }

    columns {
      name = "deaths_nhs_staff_verified"
      type = "double"
    }

    columns {
      name = "deaths_nhs_staff_awaiting"
      type = "double"
    }

    columns {
      name = "all_beds_covid_positive"
      type = "double"
    }

    columns {
      name = "hdu_itu_non_covid"
      type = "double"
    }

    columns {
      name = "hdu_itu_unoccupied"
      type = "double"
    }

    columns {
      name = "ga_covid"
      type = "double"
    }

    columns {
      name = "ga_unoccupied"
      type = "double"
    }

    columns {
      name = "ga_non_covid"
      type = "double"
    }

    columns {
      name = "absent_doctors_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_doctors_covid_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_nurses_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_nurses_covid_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_covid_ac_type_one"
      type = "double"
    }

    columns {
      name = "absent_total_ac_type_one"
      type = "double"
    }

    columns {
      name = "estimated_admissions_automated"
      type = "double"
    }

    columns {
      name = "new_community_admissions"
      type = "double"
    }

    columns {
      name = "new_community_admissions_7_lag"
      type = "double"
    }

    columns {
      name = "new_cases"
      type = "double"
    }

    columns {
      name = "estimated_admissions_care_home"
      type = "double"
    }

    columns {
      name = "f_date"
      type = "string"
    }
  }
}

resource "aws_s3_bucket_object" "api1_nhs_metrics_transform_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/api1_nhs_metrics_transform.py"
  source = "${path.module}/scripts/api1_nhs_metrics_transform.py"
  etag   = filemd5("${path.module}/scripts/api1_nhs_metrics_transform.py")
}

resource "aws_glue_job" "api1_nhs_metrics_transform" {
  name              = "api1_nhs_metrics_transform"
  description       = "Retrieves API1 metrics data from the landing bucket, transforms and outputs new data to the landing bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.api1_nhs_metrics_transform_script.bucket}/${aws_s3_bucket_object.api1_nhs_metrics_transform_script.key}"
  }



  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.api1_nhs_metrics_data_repository.name
    "--TempDir"                          = "s3://${data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name}"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }
}


resource "aws_glue_workflow" "api1_nhs_metrics" {
  name = "api1_nhs_metrics"
}

resource "aws_glue_trigger" "api1_nhs_metrics_extract" {
  name          = "api1_nhs_metrics-extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.api1_nhs_metrics.name

  actions {
    job_name = aws_glue_job.api1_nhs_metrics_extract.name
  }
}

resource "aws_glue_trigger" "api1_nhs_metrics_transform" {
  name          = "api1_nhs_metrics-transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.api1_nhs_metrics.name

  actions {
    job_name = aws_glue_job.api1_nhs_metrics_transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.api1_nhs_metrics_extract.name
      state    = "SUCCEEDED"
    }
  }
}
