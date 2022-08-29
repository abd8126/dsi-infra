import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import *

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ["JOB_NAME", "LANDING_DATABASE", "DATA_REPOSITORY_DATABASE", "TABLE_NAME","DATA_REPOSITORY_ERROR"])
unknown_string='Unknown'

nhs_region_names=["London",
               "North East and Yorkshire",
               "North West",
               "Midlands",
               "East of England",
               "South East",
               "South West",
               "England"]

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

sc.setLogLevel("ALL")
logger = glueContext.get_logger()
logger.info("Logging==========")

## @type: DataSource
## @args: [database = args["LANDING_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = args["LANDING_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "datasource0")

## @type: ApplyMapping
## @args: [mapping = [("location_type", "string", "location_type", "string"), ("location_name", "string", "location_name", "string"), ("date", "date", "date", "date"), ("metric_name", "string", "metric_name", "string"), ("metric_value", "string", "metric_value", "string"), ("unit", "string", "unit", "string")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("organisation_code", "string", "organisation_code", "string"), ("organisation_name", "string", "organisation_name", "string"), ("provider_type", "string", "provider_type", "string"), ("high_level_health_geography", "string", "high_level_health_geography", "string"), ("stp_code", "string", "stp_code", "string"), ("nhs_region_id", "string", "nhs_region_id", "string"), ("nhs_region_name", "string", "nhs_region_name", "string"), ("local_authority_id", "string", "local_authority_id", "string"), ("local_authority_name", "string", "local_authority_name", "string"), ("latitude", "double", "latitude", "double"), ("longitude", "double", "longitude", "double"), ("postcode", "string", "postcode", "string"), ("date", "string", "date", "string"), ("estimated_admissions", "double", "estimated_admissions", "double"), ("new_cases", "double", "new_cases", "double"), ("new_cases_0_to_5", "double", "new_cases_0_to_5", "double"), ("new_cases_6_to_17", "double", "new_cases_6_to_17", "double"), ("new_cases_18_to_24", "double", "new_cases_18_to_24", "double"), ("new_cases_25_to_34", "double", "new_cases_25_to_34", "double"), ("new_cases_35_to_44", "double", "new_cases_35_to_44", "double"), ("new_cases_45_to_54", "double", "new_cases_45_to_54", "double"), ("new_cases_55_to_64", "double", "new_cases_55_to_64", "double"), ("new_cases_65_to_74", "double", "new_cases_65_to_74", "double"), ("new_cases_75_to_84", "double", "new_cases_75_to_84", "double"), ("new_cases_85_plus", "double", "new_cases_85_plus", "double"), ("new_cases_unknown", "double", "new_cases_unknown", "double"), ("active_cases_0_5", "double", "active_cases_0_5", "double"), ("active_cases_6_17", "double", "active_cases_6_17", "double"), ("active_cases_18_24", "double", "active_cases_18_24", "double"), ("active_cases_25_34", "double", "active_cases_25_34", "double"), ("active_cases_35_44", "double", "active_cases_35_44", "double"), ("active_cases_45_54", "double", "active_cases_45_54", "double"), ("active_cases_55_64", "double", "active_cases_55_64", "double"), ("active_cases_65_74", "double", "active_cases_65_74", "double"), ("active_cases_75_84", "double", "active_cases_75_84", "double"), ("active_cases_85_plus", "double", "active_cases_85_plus", "double"), ("active_cases_unknown", "double", "active_cases_unknown", "double"), ("active_cases", "double", "active_cases", "double"), ("occupied_v_beds_covid", "double", "occupied_v_beds_covid", "double"), ("occupied_v_beds_non_covid", "double", "occupied_v_beds_non_covid", "double"), ("occupied_v_beds_suspected_covid", "double", "occupied_v_beds_suspected_covid", "double"), ("unoccupied_v_beds", "double", "unoccupied_v_beds", "double"), ("total_current_covid_related_absences", "double", "total_current_covid_related_absences", "double"), ("total_current_covid_related_absences_percentage", "double", "total_current_covid_related_absences_percentage", "double"), ("total_current_absences", "double", "total_current_absences", "double"), ("total_current_absences_percentage", "double", "total_current_absences_percentage", "double"), ("oxygen_cases_0_5", "double", "oxygen_cases_0_5", "double"), ("oxygen_cases_6_17", "double", "oxygen_cases_6_17", "double"), ("oxygen_cases_18_64", "double", "oxygen_cases_18_64", "double"), ("oxygen_cases_65_84", "double", "oxygen_cases_65_84", "double"), ("oxygen_cases_85_plus", "double", "oxygen_cases_85_plus", "double"), ("oxygen_cases_unknown", "double", "oxygen_cases_unknown", "double"), ("oxygen_cases", "double", "oxygen_cases", "double"), ("confirmed_in_beds_with_niv_covid", "double", "confirmed_in_beds_with_niv_covid", "double"), ("confirmed_in_beds_with_niv_non_covid", "double", "confirmed_in_beds_with_niv_non_covid", "double"), ("confirmed_in_beds_with_niv_suspected", "double", "confirmed_in_beds_with_niv_suspected", "double"), ("confirmed_unoccupied_beds_with_niv", "double", "confirmed_unoccupied_beds_with_niv", "double"), ("confirmed_in_beds_with_os_covid", "double", "confirmed_in_beds_with_os_covid", "double"), ("confirmed_in_beds_with_os_non_covid", "double", "confirmed_in_beds_with_os_non_covid", "double"), ("confirmed_in_beds_with_os_suspected", "double", "confirmed_in_beds_with_os_suspected", "double"), ("confirmed_unoccupied_beds_with_os", "double", "confirmed_unoccupied_beds_with_os", "double"), ("confirmed_in_other_beds_covid", "double", "confirmed_in_other_beds_covid", "double"), ("confirmed_in_other_beds_non_covid", "double", "confirmed_in_other_beds_non_covid", "double"), ("confirmed_in_other_beds_suspected", "double", "confirmed_in_other_beds_suspected", "double"), ("confirmed_unoccupied_other_beds", "double", "confirmed_unoccupied_other_beds", "double"), ("covid_positive_15_plus_days_after_admission", "double", "covid_positive_15_plus_days_after_admission", "double"), ("confirmed_in_hdu_itu_adult_beds_covid", "double", "confirmed_in_hdu_itu_adult_beds_covid", "double"), ("confirmed_in_hdu_itu_adult_beds_non_covid", "double", "confirmed_in_hdu_itu_adult_beds_non_covid", "double"), ("confirmed_unoccupued_in_hdu_itu_adult_beds", "double", "confirmed_unoccupued_in_hdu_itu_adult_beds", "double"), ("confirmed_in_hdu_itu_adult_beds_suspected", "double", "confirmed_in_hdu_itu_adult_beds_suspected", "double"), ("confirmed_in_hdu_itu_peadiatric_beds_covid", "double", "confirmed_in_hdu_itu_peadiatric_beds_covid", "double"), ("confirmed_in_hdu_itu_peadiatric_beds_non_covid", "double", "confirmed_in_hdu_itu_peadiatric_beds_non_covid", "double"), ("confirmed_unoccupued_in_hdu_itu_peadiatric_beds", "double", "confirmed_unoccupued_in_hdu_itu_peadiatric_beds", "double"), ("confirmed_in_hdu_itu_peadiatric_beds_suspected", "double", "confirmed_in_hdu_itu_peadiatric_beds_suspected", "double"), ("confirmed_in_ga_adult_beds_covid", "double", "confirmed_in_ga_adult_beds_covid", "double"), ("confirmed_in_ga_adult_beds_non_covid", "double", "confirmed_in_ga_adult_beds_non_covid", "double"), ("confirmed_unoccupued_in_ga_adult_beds", "double", "confirmed_unoccupued_in_ga_adult_beds", "double"), ("confirmed_in_ga_adult_beds_suspected", "double", "confirmed_in_ga_adult_beds_suspected", "double"), ("confirmed_in_ga_peadiatric_beds_covid", "double", "confirmed_in_ga_peadiatric_beds_covid", "double"), ("confirmed_in_ga_peadiatric_beds_non_covid", "double", "confirmed_in_ga_peadiatric_beds_non_covid", "double"), ("confirmed_unoccupued_in_ga_peadiatric_beds", "double", "confirmed_unoccupued_in_ga_peadiatric_beds", "double"), ("confirmed_in_ga_peadiatric_beds_suspected", "double", "confirmed_in_ga_peadiatric_beds_suspected", "double"), ("confirmed_in_ga_beds_covid", "double", "confirmed_in_ga_beds_covid", "double"), ("confirmed_in_ga_beds_non_covid", "double", "confirmed_in_ga_beds_non_covid", "double"), ("confirmed_unoccupued_in_ga_beds", "double", "confirmed_unoccupued_in_ga_beds", "double"), ("confirmed_in_ga_beds_suspected", "double", "confirmed_in_ga_beds_suspected", "double"), ("confirmed_in_hdu_itu_beds_covid", "double", "confirmed_in_hdu_itu_beds_covid", "double"), ("confirmed_in_hdu_itu_beds_non_covid", "double", "confirmed_in_hdu_itu_beds_non_covid", "double"), ("confirmed_unoccupued_in_hdu_itu_beds", "double", "confirmed_unoccupued_in_hdu_itu_beds", "double"), ("confirmed_in_hdu_itu_beds_suspected", "double", "confirmed_in_hdu_itu_beds_suspected", "double"), ("covid_related_absences_nursing_midwifery_percentage", "double", "covid_related_absences_nursing_midwifery_percentage", "double"), ("absences_nursing_midwifery_percentage", "double", "absences_nursing_midwifery_percentage", "double"), ("covid_related_absences_mdeical_dental_percentage", "double", "covid_related_absences_mdeical_dental_percentage", "double"), ("absences_medical_dental_percentage", "double", "absences_medical_dental_percentage", "double")], transformation_ctx = "applymapping1")


selectfields2 = SelectFields.apply(frame = applymapping1, paths = ["organisation_code", "organisation_name", "provider_type", "high_level_health_geography", "stp_code", "nhs_region_id", "nhs_region_name", "local_authority_id", "local_authority_name", "latitude", "longitude", "postcode", "date", "estimated_admissions", "new_cases", "new_cases_0_to_5", "new_cases_6_to_17", "new_cases_18_to_24", "new_cases_25_to_34", "new_cases_35_to_44", "new_cases_45_to_54", "new_cases_55_to_64", "new_cases_65_to_74", "new_cases_75_to_84", "new_cases_85_plus", "new_cases_unknown", "active_cases_0_5", "active_cases_6_17", "active_cases_18_24", "active_cases_25_34", "active_cases_35_44", "active_cases_45_54", "active_cases_55_64", "active_cases_65_74", "active_cases_75_84", "active_cases_85_plus", "active_cases_unknown", "active_cases", "occupied_v_beds_covid", "occupied_v_beds_non_covid", "occupied_v_beds_suspected_covid", "unoccupied_v_beds", "total_current_covid_related_absences", "total_current_covid_related_absences_percentage", "total_current_absences", "total_current_absences_percentage", "oxygen_cases_0_5", "oxygen_cases_6_17", "oxygen_cases_18_64", "oxygen_cases_65_84", "oxygen_cases_85_plus", "oxygen_cases_unknown", "oxygen_cases", "confirmed_in_beds_with_niv_covid", "confirmed_in_beds_with_niv_non_covid", "confirmed_in_beds_with_niv_suspected", "confirmed_unoccupied_beds_with_niv", "confirmed_in_beds_with_os_covid", "confirmed_in_beds_with_os_non_covid", "confirmed_in_beds_with_os_suspected", "confirmed_unoccupied_beds_with_os", "confirmed_in_other_beds_covid", "confirmed_in_other_beds_non_covid", "confirmed_in_other_beds_suspected", "confirmed_unoccupied_other_beds", "covid_positive_15_plus_days_after_admission", "confirmed_in_hdu_itu_adult_beds_covid", "confirmed_in_hdu_itu_adult_beds_non_covid", "confirmed_unoccupued_in_hdu_itu_adult_beds", "confirmed_in_hdu_itu_adult_beds_suspected", "confirmed_in_hdu_itu_peadiatric_beds_covid", "confirmed_in_hdu_itu_peadiatric_beds_non_covid", "confirmed_unoccupued_in_hdu_itu_peadiatric_beds", "confirmed_in_hdu_itu_peadiatric_beds_suspected", "confirmed_in_ga_adult_beds_covid", "confirmed_in_ga_adult_beds_non_covid", "confirmed_unoccupued_in_ga_adult_beds", "confirmed_in_ga_adult_beds_suspected", "confirmed_in_ga_peadiatric_beds_covid", "confirmed_in_ga_peadiatric_beds_non_covid", "confirmed_unoccupued_in_ga_peadiatric_beds", "confirmed_in_ga_peadiatric_beds_suspected", "confirmed_in_ga_beds_covid", "confirmed_in_ga_beds_non_covid", "confirmed_unoccupued_in_ga_beds", "confirmed_in_ga_beds_suspected", "confirmed_in_hdu_itu_beds_covid", "confirmed_in_hdu_itu_beds_non_covid", "confirmed_unoccupued_in_hdu_itu_beds", "confirmed_in_hdu_itu_beds_suspected", "covid_related_absences_nursing_midwifery_percentage", "absences_nursing_midwifery_percentage", "covid_related_absences_mdeical_dental_percentage", "absences_medical_dental_percentage"], transformation_ctx = "selectfields2")

resolvechoice3 = ResolveChoice.apply(frame = selectfields2, choice = "MATCH_CATALOG", database = args["DATA_REPOSITORY_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "resolvechoice3")

val_spark_df=resolvechoice3.toDF()

val_out_spark_df2 = val_spark_df.withColumn('nhs_region_name_good',when(col("nhs_region_name").isin(*nhs_region_names), val_spark_df.nhs_region_name).otherwise("Unknown"))

logger.info("Dataframe consists of {} entries".format((val_out_spark_df2.count())))

logger.info("Create dataframe of errors")
val_out_spark_errors = val_out_spark_df2.filter(f'nhs_region_name_good="Unknown" ')

errors_count = (val_out_spark_errors.count())

logger.info('Log count of errors')
logger.info("Errors: {}".format(errors_count))


val_out_spark_dyf = DynamicFrame.fromDF(val_out_spark_df2, glueContext, 'val_out_spark_dyf')
val_out_spark_errors_df = DynamicFrame.fromDF(val_out_spark_errors, glueContext, 'val_out_spark_errors_df')

if errors_count == 0:
   logger.info("Writing data to the s3/Glue table")
   datasink4 = glueContext.write_dynamic_frame.from_catalog(
        frame = val_out_spark_dyf, 
        database = args["DATA_REPOSITORY_DATABASE"], 
        table_name = args["TABLE_NAME"], 
        transformation_ctx = "datasink4"
   )
   logger.info("Data moved to data repository")
else:
    logger.info("Errors found, data not placed in data repository")
    

job.commit()

logger.info("Job completed ")
