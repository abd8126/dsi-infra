resource "aws_glue_catalog_table" "cqc_social_care_daily_details_landing" {
  name          = "cqc_social_care_daily_details"
  database_name = data.terraform_remote_state.base.outputs.landing_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
    "typeOfData"     = "file"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name}/SitCen/cqc-social-care-daily-details-api6"
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
      name = "offset"
      type = "int"
    }

    columns {
      name = "limit"
      type = "int"
    }

    columns {
      name = "totalitems"
      type = "int"
    }

    columns {
      name = "items"
      type = "array<struct<cqcId:string,odsCode:string,ccgOdsCode:string,laSnacCode:string,vacanciesLastUpdated:string,isCareHome:boolean,isAcute:boolean,isCommunity:boolean,isHospice:boolean,isSubstanceMisuse:boolean,admissionStatus:string,homePressure:int,vacancies:array<struct<bedType:string,total:int,spare:int,isClosedToAdmissions:boolean>>,workforce:struct<nursesAbsent:int,nursesAbsentCovid:int,nursesEmployed:int,careWorkersAbsent:int,careWorkersAbsentCovid:int,careWorkersEmployed:int,nonCareWorkersAbsent:int,nonCareWorkersAbsentCovid:int,nonCareWorkersEmployed:int,agencyNursesEmployed:int,agencyCareWorkersEmployed:int,agencyNonCareWorkersEmployed:int,workforcePressure:int>,ppe:struct<aprons:int,eyes:int,gloves:int,masks:int,sanitiser:int>,ascSupport:struct<canCreateIsolationBeds:string,canCreateIsolationBedsLastModified:string,isStaffMovementRestricted:string,isStaffMovementRestrictedLastModified:string,areStaffIsolating:string,areStaffIsolatingLastModified:string,hasReducedPublicTransport:string,hasReducedPublicTransportLastModified:string,staffLivingAloneCount:int,staffLivingAloneCountLastModified:string,staffLivingAloneCountWithAccomodation:int,staffLivingAloneCountWithAccomodationLastModified:string,isVisitingAllowed:string,isVisitingAllowedLastModified:string,isVisitingAllowedOutdoors:boolean,isVisitingAllowedOutdoorsLastModified:string,isVisitingAllowedInside:boolean,isVisitingAllowedInsideLastModified:string,isVisitingAllowedInsideNonSecure:boolean,isVisitingAllowedInsideNonSecureLastModified:string,isVisitingAllowedBedrooms:boolean,isVisitingAllowedBedroomsLastModified:string,visitingIssues:int,visitingIssuesLastModified:string,staffTestedCovid7d:int,staffTestedCovid7dLastModified:string,staffNotTestedCovid7d:int,staffNotTestedCovid7dLastModified:string,staffNATestedCovid7d:int,staffNATestedCovid7dLastModified:string,staffTestedCovidPaid:string,staffTestedCovidPaidLastModified:string,hasMedicalEquipmentAccess:string,hasMedicalEquipmentAccessLastModified:string,hasStaffInfectionTraining:string,hasStaffInfectionTrainingLastModified:string,requiresInfectionTraining:string,requiresInfectionTrainingLastModified:string,hasStaffIpcTraining:string,hasStaffIpcTrainingLastModified:string,hasStaffIpcUpdates:string,hasStaffIpcUpdatesLastModified:string,hasIdentifiedPcnLead:string,hasIdentifiedPcnLeadLastModified:string,hasWeeklyCheckin:string,hasWeeklyCheckinLastModified:string,agencyRestrictiveMeasures:int,agencyRestrictiveMeasuresLastModified:string,monthlyLastUpdated:string,weeklyLastUpdated:string>,covid:struct<covid19LastUpdated:string,covidStaffSuspected24h:int,covidStaffConfirmed24h:int,covidResidentsSuspected24h:int,covidResidentsConfirmed24h:int,covidResidentsExternal24h:int,covidResidentsTotal:int,covidAdmissions:int,trustAdmissionsPositive:int,trustAdmissionsNegative:int,trustAdmissionsPending:int,trustAdmissionsPendingOdsCodes:string,trustAdmissionsNotTested:int,trustAdmissionsNotTestedOdsCodes:string,trustAdmissionsUnknownTested:int,vaccinations:struct<dose1:struct<residentsYes:int,residentsNo:int,residentsUnknown:int,staffYes:int,staffNo:int,staffUnknown:int,agencyYes:int,agencyNo:int,agencyUnknown:int>,haveHadVisit:string,isVisitBooked:string,isExtraVisitRequired:string>>,flu:struct<residentsImmunised:int,residentsNotImmunised:int,residentsUnknownImmunised:int,staffImmunised:int,staffNotImmunised:int,staffUnknownImmunised:int,agencyImmunised:int,agencyNotImmunised:int,agencyUnknownImmunised:int,fluHasDelaysResidents:boolean,fluHasDelaysStaff:boolean>>>"
    }
  }
}

resource "aws_s3_bucket_object" "cqc_social_care_daily_details_extract_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/cqc_social_care_daily_details_extract.py"
  source = "${path.module}/scripts/cqc_social_care_daily_details_extract.py"
  etag   = filemd5("${path.module}/scripts/cqc_social_care_daily_details_extract.py")
}

resource "aws_glue_job" "cqc_social_care_daily_details_extract" {
  name         = "cqc_social_care_daily_details_extract"
  description  = "Pulls data from the cqc_social_care_daily_details (API 6) endpoint and stores it in the landing bucket"
  role_arn     = aws_iam_role.sitcen_glue_jobs.arn
  max_capacity = "0.0625"
  glue_version = "1.0"
  connections  = [data.terraform_remote_state.base.outputs.glue_private_subnet_connection_id]

  command {
    name            = "pythonshell"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket_object.cqc_social_care_daily_details_extract_script.bucket}/${aws_s3_bucket_object.cqc_social_care_daily_details_extract_script.key}"
  }

  default_arguments = {
    "--SECRET_ID"                = "DSI/api_6"
    "--LANDING_BUCKET"           = data.terraform_remote_state.tenant.outputs.tenant_landing_bucket_name
    "--TempDir"                  = data.terraform_remote_state.base.outputs.glue_temp_dir_bucket_name
    "--enable-metrics"           = ""
    "--LANDING_DATABASE"         = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--REPOSITORY_BUCKET"        = data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name
    "--DATA_REPOSITORY_DATABASE" = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"               = aws_glue_catalog_table.cqc_social_care_daily_details_data_repository.name
  }
}

resource "aws_glue_catalog_table" "cqc_social_care_daily_details_data_repository" {
  name          = aws_glue_catalog_table.cqc_social_care_daily_details_landing.name
  database_name = data.terraform_remote_state.base.outputs.data_repository_glue_database_name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification" = "json"
    "typeOfData"     = "file"
  }

  storage_descriptor {
    location      = "s3://${data.terraform_remote_state.tenant.outputs.tenant_repository_bucket_name}/SitCen/repository/cqc-social-care-daily-details-api6"
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
      name = "offset"
      type = "int"
    }

    columns {
      name = "limit"
      type = "int"
    }

    columns {
      name = "totalitems"
      type = "int"
    }

    columns {
      name = "items"
      type = "array<struct<cqcId:string,odsCode:string,ccgOdsCode:string,laSnacCode:string,vacanciesLastUpdated:string,isCareHome:boolean,isAcute:boolean,isCommunity:boolean,isHospice:boolean,isSubstanceMisuse:boolean,admissionStatus:string,homePressure:int,vacancies:array<struct<bedType:string,total:int,spare:int,isClosedToAdmissions:boolean>>,workforce:struct<nursesAbsent:int,nursesAbsentCovid:int,nursesEmployed:int,careWorkersAbsent:int,careWorkersAbsentCovid:int,careWorkersEmployed:int,nonCareWorkersAbsent:int,nonCareWorkersAbsentCovid:int,nonCareWorkersEmployed:int,agencyNursesEmployed:int,agencyCareWorkersEmployed:int,agencyNonCareWorkersEmployed:int,workforcePressure:int>,ppe:struct<aprons:int,eyes:int,gloves:int,masks:int,sanitiser:int>,ascSupport:struct<canCreateIsolationBeds:string,canCreateIsolationBedsLastModified:string,isStaffMovementRestricted:string,isStaffMovementRestrictedLastModified:string,areStaffIsolating:string,areStaffIsolatingLastModified:string,hasReducedPublicTransport:string,hasReducedPublicTransportLastModified:string,staffLivingAloneCount:int,staffLivingAloneCountLastModified:string,staffLivingAloneCountWithAccomodation:int,staffLivingAloneCountWithAccomodationLastModified:string,isVisitingAllowed:string,isVisitingAllowedLastModified:string,isVisitingAllowedOutdoors:boolean,isVisitingAllowedOutdoorsLastModified:string,isVisitingAllowedInside:boolean,isVisitingAllowedInsideLastModified:string,isVisitingAllowedInsideNonSecure:boolean,isVisitingAllowedInsideNonSecureLastModified:string,isVisitingAllowedBedrooms:boolean,isVisitingAllowedBedroomsLastModified:string,visitingIssues:int,visitingIssuesLastModified:string,staffTestedCovid7d:int,staffTestedCovid7dLastModified:string,staffNotTestedCovid7d:int,staffNotTestedCovid7dLastModified:string,staffNATestedCovid7d:int,staffNATestedCovid7dLastModified:string,staffTestedCovidPaid:string,staffTestedCovidPaidLastModified:string,hasMedicalEquipmentAccess:string,hasMedicalEquipmentAccessLastModified:string,hasStaffInfectionTraining:string,hasStaffInfectionTrainingLastModified:string,requiresInfectionTraining:string,requiresInfectionTrainingLastModified:string,hasStaffIpcTraining:string,hasStaffIpcTrainingLastModified:string,hasStaffIpcUpdates:string,hasStaffIpcUpdatesLastModified:string,hasIdentifiedPcnLead:string,hasIdentifiedPcnLeadLastModified:string,hasWeeklyCheckin:string,hasWeeklyCheckinLastModified:string,agencyRestrictiveMeasures:int,agencyRestrictiveMeasuresLastModified:string,monthlyLastUpdated:string,weeklyLastUpdated:string>,covid:struct<covid19LastUpdated:string,covidStaffSuspected24h:int,covidStaffConfirmed24h:int,covidResidentsSuspected24h:int,covidResidentsConfirmed24h:int,covidResidentsExternal24h:int,covidResidentsTotal:int,covidAdmissions:int,trustAdmissionsPositive:int,trustAdmissionsNegative:int,trustAdmissionsPending:int,trustAdmissionsPendingOdsCodes:string,trustAdmissionsNotTested:int,trustAdmissionsNotTestedOdsCodes:string,trustAdmissionsUnknownTested:int,vaccinations:struct<dose1:struct<residentsYes:int,residentsNo:int,residentsUnknown:int,staffYes:int,staffNo:int,staffUnknown:int,agencyYes:int,agencyNo:int,agencyUnknown:int>,haveHadVisit:string,isVisitBooked:string,isExtraVisitRequired:string>>,flu:struct<residentsImmunised:int,residentsNotImmunised:int,residentsUnknownImmunised:int,staffImmunised:int,staffNotImmunised:int,staffUnknownImmunised:int,agencyImmunised:int,agencyNotImmunised:int,agencyUnknownImmunised:int,fluHasDelaysResidents:boolean,fluHasDelaysStaff:boolean>>>"
    }
  }
}

resource "aws_s3_bucket_object" "cqc_social_care_daily_details_transform_script" {
  bucket = data.terraform_remote_state.base.outputs.data_pipeline_scripts_bucket_name
  key    = "sitcen/cqc_social_care_daily_details_transform.py"
  source = "${path.module}/scripts/cqc_social_care_daily_details_transform.py"
  etag   = filemd5("${path.module}/scripts/cqc_social_care_daily_details_transform.py")
}

resource "aws_glue_job" "cqc_social_care_daily_details_transform" {
  name              = "cqc_social_care_daily_details_transform"
  description       = "Retrieves cqc_social_care_daily_details data from the landing bucket and outputs new data to the data repository bucket"
  role_arn          = aws_iam_role.sitcen_glue_jobs.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket_object.cqc_social_care_daily_details_transform_script.bucket}/${aws_s3_bucket_object.cqc_social_care_daily_details_transform_script.key}"
  }



  default_arguments = {
    "--LANDING_DATABASE"                 = data.terraform_remote_state.base.outputs.landing_glue_database_name
    "--DATA_REPOSITORY_DATABASE"         = data.terraform_remote_state.base.outputs.data_repository_glue_database_name
    "--TABLE_NAME"                       = aws_glue_catalog_table.cqc_social_care_daily_details_data_repository.name
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


resource "aws_glue_workflow" "cqc_social_care_daily_details" {
  name = "cqc_social_care_daily_details"
}

resource "aws_glue_trigger" "cqc_social_care_daily_details_extract" {
  name          = "cqc_social_care_daily_details_extract"
  schedule      = "cron(0 8 * * ? *)"
  type          = "SCHEDULED"
  workflow_name = aws_glue_workflow.cqc_social_care_daily_details.name

  actions {
    job_name = aws_glue_job.cqc_social_care_daily_details_extract.name
  }
}

resource "aws_glue_trigger" "cqc_social_care_daily_details_transform" {
  name          = "cqc_social_care_daily_details_transform"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.cqc_social_care_daily_details.name

  actions {
    job_name = aws_glue_job.cqc_social_care_daily_details_transform.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.cqc_social_care_daily_details_extract.name
      state    = "SUCCEEDED"
    }
  }
}
