resource "aws_glue_catalog_table" "api1_admission_metrics_landing" {
  name          = "api1_admission_metrics"
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
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/admission-metrics-api1"
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
      type = "double"

    }
    columns {
      name = "longitude"
      type = "double"

    }
    columns {
      name = "postcode"
      type = "string"

    }
    columns {
      name = "date"
      type = "string"

    }
    columns {
      name = "estimated_admissions"
      type = "double"

    }
    columns {
      name = "new_cases"
      type = "double"

    }
    columns {
      name = "new_cases_0_to_5"
      type = "double"

    }
    columns {
      name = "new_cases_6_to_17"
      type = "double"

    }
    columns {
      name = "new_cases_18_to_24"
      type = "double"

    }
    columns {
      name = "new_cases_25_to_34"
      type = "double"

    }
    columns {
      name = "new_cases_35_to_44"
      type = "double"

    }
    columns {
      name = "new_cases_45_to_54"
      type = "double"

    }
    columns {
      name = "new_cases_55_to_64"
      type = "double"

    }
    columns {
      name = "new_cases_65_to_74"
      type = "double"

    }
    columns {
      name = "new_cases_75_to_84"
      type = "double"

    }
    columns {
      name = "new_cases_85_plus"
      type = "double"

    }
    columns {
      name = "new_cases_unknown"
      type = "double"

    }
    columns {
      name = "active_cases_0_5"
      type = "double"

    }
    columns {
      name = "active_cases_6_17"
      type = "double"

    }
    columns {
      name = "active_cases_18_24"
      type = "double"

    }
    columns {
      name = "active_cases_25_34"
      type = "double"

    }
    columns {
      name = "active_cases_35_44"
      type = "double"

    }
    columns {
      name = "active_cases_45_54"
      type = "double"

    }
    columns {
      name = "active_cases_55_64"
      type = "double"

    }
    columns {
      name = "active_cases_65_74"
      type = "double"

    }
    columns {
      name = "active_cases_75_84"
      type = "double"

    }
    columns {
      name = "active_cases_85_plus"
      type = "double"

    }
    columns {
      name = "active_cases_unknown"
      type = "double"

    }
    columns {
      name = "active_cases"
      type = "double"

    }
    columns {
      name = "occupied_v_beds_covid"
      type = "double"

    }
    columns {
      name = "occupied_v_beds_non_covid"
      type = "double"

    }
    columns {
      name = "occupied_v_beds_suspected_covid"
      type = "double"

    }
    columns {
      name = "unoccupied_v_beds"
      type = "double"

    }
    columns {
      name = "total_current_covid_related_absences"
      type = "double"

    }
    columns {
      name = "total_current_covid_related_absences_percentage"
      type = "double"

    }
    columns {
      name = "total_current_absences"
      type = "double"

    }
    columns {
      name = "total_current_absences_percentage"
      type = "double"

    }
    columns {
      name = "oxygen_cases_0_5"
      type = "double"

    }
    columns {
      name = "oxygen_cases_6_17"
      type = "double"

    }
    columns {
      name = "oxygen_cases_18_64"
      type = "double"

    }
    columns {
      name = "oxygen_cases_65_84"
      type = "double"

    }
    columns {
      name = "oxygen_cases_85_plus"
      type = "double"

    }
    columns {
      name = "oxygen_cases_unknown"
      type = "double"

    }
    columns {
      name = "oxygen_cases"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_niv_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_niv_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_niv_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupied_beds_with_niv"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_os_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_os_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_os_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupied_beds_with_os"
      type = "double"

    }
    columns {
      name = "confirmed_in_other_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_other_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_other_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupied_other_beds"
      type = "double"

    }
    columns {
      name = "covid_positive_15_plus_days_after_admission"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_adult_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_adult_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_hdu_itu_adult_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_adult_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_peadiatric_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_peadiatric_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_hdu_itu_peadiatric_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_peadiatric_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_adult_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_adult_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_ga_adult_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_adult_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_peadiatric_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_peadiatric_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_ga_peadiatric_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_peadiatric_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_ga_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_hdu_itu_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_beds_suspected"
      type = "double"

    }
    columns {
      name = "covid_related_absences_nursing_midwifery_percentage"
      type = "double"

    }
    columns {
      name = "absences_nursing_midwifery_percentage"
      type = "double"

    }
    columns {
      name = "covid_related_absences_mdeical_dental_percentage"
      type = "double"

    }
    columns {
      name = "absences_medical_dental_percentage"
      type = "double"

    }

  }
}

resource "aws_s3_bucket_object" "API1_admission_Metrics_extract_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/Import_API1_Admission_Metrics.py"
  source = "${path.module}/scripts/Import_API1_Admission_Metrics.py"
  etag   = filemd5("${path.module}/scripts/Import_API1_Admission_Metrics.py")
}

resource "aws_glue_job" "API1_admission_Metrics_extract" {
  name         = "API1_admission_Metrics_extract"
  description  = "Pulls data from the API1_admission_Metrics endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.API1_admission_Metrics_extract_script.bucket}/${aws_s3_bucket_object.API1_admission_Metrics_extract_script.key}"
  }

  #location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/sitcen/API1_admission_Metrics"
  #"--LANDING_BUCKET" = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name

  default_arguments = {
    "--SECRET_ID"                = "DSI/API00001_Admission_Metrics"
    "--LANDING_BUCKET"           = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--DATA_REPOSITORY_DATABASE" = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"               = aws_glue_catalog_table.api1_admission_metrics_data_repository.name
    "--DATA_REPOSITORY_ERROR"    = "s3://${data.terraform_remote_state.base.outputs.data_repository_glue_database_name}/API1_admission_Metrics/Errors"
    "--TempDir"                  = data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name
    "--enable-metrics"           = ""
  }
}


resource "aws_glue_catalog_table" "api1_admission_metrics_data_repository" {
  name          = aws_glue_catalog_table.api1_admission_metrics_landing.name
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
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/admission-metrics-api1"
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
      type = "double"

    }
    columns {
      name = "longitude"
      type = "double"

    }
    columns {
      name = "postcode"
      type = "string"

    }
    columns {
      name = "date"
      type = "string"

    }
    columns {
      name = "estimated_admissions"
      type = "double"

    }
    columns {
      name = "new_cases"
      type = "double"

    }
    columns {
      name = "new_cases_0_to_5"
      type = "double"

    }
    columns {
      name = "new_cases_6_to_17"
      type = "double"

    }
    columns {
      name = "new_cases_18_to_24"
      type = "double"

    }
    columns {
      name = "new_cases_25_to_34"
      type = "double"

    }
    columns {
      name = "new_cases_35_to_44"
      type = "double"

    }
    columns {
      name = "new_cases_45_to_54"
      type = "double"

    }
    columns {
      name = "new_cases_55_to_64"
      type = "double"

    }
    columns {
      name = "new_cases_65_to_74"
      type = "double"

    }
    columns {
      name = "new_cases_75_to_84"
      type = "double"

    }
    columns {
      name = "new_cases_85_plus"
      type = "double"

    }
    columns {
      name = "new_cases_unknown"
      type = "double"

    }
    columns {
      name = "active_cases_0_5"
      type = "double"

    }
    columns {
      name = "active_cases_6_17"
      type = "double"

    }
    columns {
      name = "active_cases_18_24"
      type = "double"

    }
    columns {
      name = "active_cases_25_34"
      type = "double"

    }
    columns {
      name = "active_cases_35_44"
      type = "double"

    }
    columns {
      name = "active_cases_45_54"
      type = "double"

    }
    columns {
      name = "active_cases_55_64"
      type = "double"

    }
    columns {
      name = "active_cases_65_74"
      type = "double"

    }
    columns {
      name = "active_cases_75_84"
      type = "double"

    }
    columns {
      name = "active_cases_85_plus"
      type = "double"

    }
    columns {
      name = "active_cases_unknown"
      type = "double"

    }
    columns {
      name = "active_cases"
      type = "double"

    }
    columns {
      name = "occupied_v_beds_covid"
      type = "double"

    }
    columns {
      name = "occupied_v_beds_non_covid"
      type = "double"

    }
    columns {
      name = "occupied_v_beds_suspected_covid"
      type = "double"

    }
    columns {
      name = "unoccupied_v_beds"
      type = "double"

    }
    columns {
      name = "total_current_covid_related_absences"
      type = "double"

    }
    columns {
      name = "total_current_covid_related_absences_percentage"
      type = "double"

    }
    columns {
      name = "total_current_absences"
      type = "double"

    }
    columns {
      name = "total_current_absences_percentage"
      type = "double"

    }
    columns {
      name = "oxygen_cases_0_5"
      type = "double"

    }
    columns {
      name = "oxygen_cases_6_17"
      type = "double"

    }
    columns {
      name = "oxygen_cases_18_64"
      type = "double"

    }
    columns {
      name = "oxygen_cases_65_84"
      type = "double"

    }
    columns {
      name = "oxygen_cases_85_plus"
      type = "double"

    }
    columns {
      name = "oxygen_cases_unknown"
      type = "double"

    }
    columns {
      name = "oxygen_cases"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_niv_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_niv_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_niv_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupied_beds_with_niv"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_os_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_os_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_beds_with_os_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupied_beds_with_os"
      type = "double"

    }
    columns {
      name = "confirmed_in_other_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_other_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_other_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupied_other_beds"
      type = "double"

    }
    columns {
      name = "covid_positive_15_plus_days_after_admission"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_adult_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_adult_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_hdu_itu_adult_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_adult_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_peadiatric_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_peadiatric_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_hdu_itu_peadiatric_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_peadiatric_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_adult_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_adult_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_ga_adult_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_adult_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_peadiatric_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_peadiatric_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_ga_peadiatric_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_peadiatric_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_ga_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_ga_beds_suspected"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_beds_covid"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_beds_non_covid"
      type = "double"

    }
    columns {
      name = "confirmed_unoccupued_in_hdu_itu_beds"
      type = "double"

    }
    columns {
      name = "confirmed_in_hdu_itu_beds_suspected"
      type = "double"

    }
    columns {
      name = "covid_related_absences_nursing_midwifery_percentage"
      type = "double"

    }
    columns {
      name = "absences_nursing_midwifery_percentage"
      type = "double"

    }
    columns {
      name = "covid_related_absences_mdeical_dental_percentage"
      type = "double"

    }
    columns {
      name = "absences_medical_dental_percentage"
      type = "double"

    }
  }
}


resource "aws_s3_bucket_object" "API1_admission_Metrics_transform_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/Transform_API1_Admission_Metrics.py"
  source = "${path.module}/scripts/Transform_API1_Admission_Metrics.py"
  etag   = filemd5("${path.module}/scripts/Transform_API1_Admission_Metrics.py")
}

resource "aws_glue_job" "API1_admission_Metrics_transform" {
  name              = "API1_admission_Metrics_transform"
  description       = "Retrieves boc data from the landing bucket, transforms and outputs new data to the landing bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.API1_admission_Metrics_transform_script.bucket}/${aws_s3_bucket_object.API1_admission_Metrics_transform_script.key}"
  }


  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.api1_admission_metrics_data_repository.name
    "--DATA_REPOSITORY_ERROR"            = "s3://${data.terraform_remote_state.base.outputs.data_repository_glue_database_name}/API1_admission_Metrics/Errors"
    "--TempDir"                          = "s3://${data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name}"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }
}


resource "aws_glue_workflow" "API1_admission_Metrics" {
  name = "API1_admission_Metrics"
}

resource "aws_glue_trigger" "API1_admission_Metrics_extract" {
  name          = "API1_admission_Metrics-extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.API1_admission_Metrics.name

  actions {
    job_name = aws_glue_job.API1_admission_Metrics_extract.name
  }
}

resource "aws_glue_trigger" "API1_admission_Metrics_transform" {
  name          = "API1_admission_Metrics-transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.API1_admission_Metrics.name

  actions {
    job_name = aws_glue_job.API1_admission_Metrics_transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.API1_admission_Metrics_extract.name
      state    = "SUCCEEDED"
    }
  }
}
