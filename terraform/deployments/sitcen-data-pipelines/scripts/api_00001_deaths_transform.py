import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import *

provider_types = ["Acute Trust with Type 1", "Acute Trust"]


nhs_region_names = [
                        "East of England",
                        "Midlands",
                        "London",
                        "South East",
                        "North East and Yorkshire",
                        "North West",
                        "South West",
                    ]

nhs_region_ids = [
                        "E40000007",
                        "E40000008",
                        "E40000003",
                        "E40000005",
                        "E40000009",
                        "E40000010",
                        "E40000006",
                    ]

high_level_health_geographys = [
                        "Q79",
                        "Q78",
                        "Q71",
                        "Q77",
                        "Q87",
                        "Q74",
                        "Q75",
                        "Q76",
                        "Q85",
                        "Q88",
                        "Q72",
                        "Q86",
                        "Q84",
                        "QVV",
                        "Q83",
                    ]

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ["JOB_NAME", "LANDING_DATABASE", "DATA_REPOSITORY_DATABASE", "TABLE_NAME"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

sc.setLogLevel("ALL")
logger = glueContext.get_logger()

datasource0 = glueContext.create_dynamic_frame.from_catalog(database=args["LANDING_DATABASE"], table_name=args["TABLE_NAME"], transformation_ctx="datasource0")
new_record_count = datasource0.count()

applymapping1 = ApplyMapping.apply(frame=datasource0, mappings = [("organisation_code", "string", "organisation_code", "string"), ("organisation_name", "string", "organisation_name", "string"), ("provider_type", "string", "provider_type", "string"), ("high_level_health_geography", "string", "high_level_health_geography", "string"), ("stp_code", "string", "stp_code", "string"), ("nhs_region_id", "string", "nhs_region_id", "string"), ("nhs_region_name", "string", "nhs_region_name", "string"), ("local_authority_id", "string", "local_authority_id", "string"), ("local_authority_name", "string", "local_authority_name", "string"), ("latitude", "decimal(10,2)", "latitude", "double"), ("longitude", "decimal(10,2)", "longitude", "double"), ("postcode", "string", "postcode", "string"), ("date", "date", "date", "date"), ("new_deaths", "int", "new_deaths", "int"), ("new_deaths_0_to_19", "int", "new_deaths_0_to_19", "int"), ("new_deaths_20_to_39", "int", "new_deaths_20_to_39", "int"), ("new_deaths_40_to_59", "int", "new_deaths_40_to_59", "int"), ("new_deaths_60_to_79", "int", "new_deaths_60_to_79", "int"), ("new_deaths_80+", "int", "new_deaths_80+", "int"), ("new_deaths_asthma", "int", "new_deaths_asthma", "int"), ("new_deaths_chronic_kidney_disease", "int", "new_deaths_chronic_kidney_disease", "int"), ("new_deaths_chronic_neurological_disorder", "int", "new_deaths_chronic_neurological_disorder", "int"), ("new_deaths_chronic_pulmonary_disease", "int", "new_deaths_chronic_pulmonary_disease", "int"), ("new_deaths_dementia", "int", "new_deaths_dementia", "int"), ("new_deaths_diabetes", "int", "new_deaths_diabetes", "int"), ("new_deaths_ethnicity_african", "int", "new_deaths_ethnicity_african", "int"), ("new_deaths_ethnicity_asian_other", "int", "new_deaths_ethnicity_asian_other", "int"), ("new_deaths_ethnicity_bangladeshi", "int", "new_deaths_ethnicity_bangladeshi", "int"), ("new_deaths_ethnicity_black_other", "int", "new_deaths_ethnicity_black_other", "int"), ("new_deaths_ethnicity_british", "int", "new_deaths_ethnicity_british", "int"), ("new_deaths_ethnicity_caribbean", "int", "new_deaths_ethnicity_caribbean", "int"), ("new_deaths_ethnicity_chinese", "int", "new_deaths_ethnicity_chinese", "int"), ("new_deaths_ethnicity_indian", "int", "new_deaths_ethnicity_indian", "int"), ("new_deaths_ethnicity_irish", "int", "new_deaths_ethnicity_irish", "int"), ("new_deaths_ethnicity_mixed_other", "int", "new_deaths_ethnicity_mixed_other", "int"), ("new_deaths_ethnicity_other", "int", "new_deaths_ethnicity_other", "int"), ("new_deaths_ethnicity_pakistani", "int", "new_deaths_ethnicity_pakistani", "int"), ("new_deaths_ethnicity_white_and_asian", "int", "new_deaths_ethnicity_white_and_asian", "int"), ("new_deaths_ethnicity_white_and_black_african", "int", "new_deaths_ethnicity_white_and_black_african", "int"), ("new_deaths_ethnicity_white_and_black_caribbean", "int", "new_deaths_ethnicity_white_and_black_caribbean", "int"), ("new_deaths_ethnicity_white_other", "int", "new_deaths_ethnicity_white_other", "int"), ("new_deaths_gender_female", "int", "new_deaths_gender_female", "int"), ("new_deaths_gender_male", "int", "new_deaths_gender_male", "int"), ("new_deaths_ischaemic_heart_disease", "int", "new_deaths_ischaemic_heart_disease", "int"), ("new_deaths_obesity", "int", "new_deaths_obesity", "int"), ("new_deaths_other_condition", "int", "new_deaths_other_condition", "int"), ("new_deaths_rheumatological_disorder", "int", "new_deaths_rheumatological_disorder", "int")], transformation_ctx="applymapping1")

selectfields2 = SelectFields.apply(frame=applymapping1, paths = ["date", "new_deaths_ethnicity_other", "new_deaths_ethnicity_white_other", "nhs_region_name", "new_deaths_ethnicity_white_and_black_caribbean", "new_deaths_dementia", "new_deaths_ethnicity_asian_other", "local_authority_id", "new_deaths_80+", "new_deaths_ethnicity_chinese", "new_deaths_ethnicity_irish", "local_authority_name", "new_deaths_ethnicity_white_and_black_african", "nhs_region_id", "new_deaths_ethnicity_caribbean", "latitude", "new_deaths_ethnicity_indian", "new_deaths_chronic_neurological_disorder", "new_deaths_60_to_79", "new_deaths_0_to_19", "organisation_code", "organisation_name", "provider_type", "stp_code", "new_deaths_ethnicity_mixed_other", "new_deaths_asthma", "new_deaths_rheumatological_disorder", "new_deaths_40_to_59", "new_deaths_ethnicity_white_and_asian", "new_deaths_ischaemic_heart_disease", "new_deaths_ethnicity_pakistani", "new_deaths_chronic_kidney_disease", "new_deaths_ethnicity_african", "new_deaths_ethnicity_black_other", "longitude", "new_deaths_other_condition", "new_deaths_ethnicity_bangladeshi", "new_deaths_20_to_39", "postcode", "new_deaths_gender_female", "new_deaths_ethnicity_british", "new_deaths", "new_deaths_diabetes", "new_deaths_gender_male", "new_deaths_obesity", "new_deaths_chronic_pulmonary_disease", "high_level_health_geography"], transformation_ctx="selectfields2")

resolvechoice3 = ResolveChoice.apply(frame=selectfields2, choice = "MATCH_CATALOG", database=args["DATA_REPOSITORY_DATABASE"], table_name=args["TABLE_NAME"], transformation_ctx="resolvechoice3")

val_spark_df=resolvechoice3.toDF()

val_out_spark_df1 = val_spark_df.withColumn('provider_type_good',when(col("provider_type").isin(*provider_types), val_spark_df.provider_type).otherwise("Unknown"))

val_out_spark_df2 = val_out_spark_df1.withColumn('nhs_region_name_good',when(col("nhs_region_name").isin(*nhs_region_names), val_spark_df.nhs_region_name).otherwise("Unknown"))

val_out_spark_df3 = val_out_spark_df2.withColumn('nhs_region_id_good',when(col("nhs_region_id").isin(*nhs_region_ids), val_spark_df.nhs_region_id).otherwise("Unknown"))

val_out_spark_df4 = val_out_spark_df3.withColumn('high_level_health_geography_good',when(col("high_level_health_geography").isin(*high_level_health_geographys), val_spark_df.high_level_health_geography).otherwise("Unknown"))

logger.info("Create dataframe of errors")
val_out_spark_errors = val_out_spark_df4.filter('provider_type_good="Unknown" or nhs_region_name_good="Unknown" or nhs_region_id_good="Unknown" or high_level_health_geography_good="Unknown"')

error_count = val_out_spark_errors.count()

logger.info(f'New records : {new_record_count}')
logger.info('Log count of errorts')
logger.info(f'Errors: {error_count}')
if error_count > 0:
    logger.warn(
        f"""output_table: {args['TABLE_NAME']}\n
        errors : {error_count}""")
    raise Exception("Errors in transformation")

val_out_spark_dyf = DynamicFrame.fromDF(val_out_spark_df2, glueContext, 'val_out_spark_dyf')
datasink4 = glueContext.write_dynamic_frame.from_catalog(frame=resolvechoice3, database=args["DATA_REPOSITORY_DATABASE"], table_name=args["TABLE_NAME"], transformation_ctx="datasink4")

## @inputs: [frame=resolvechoice3]
datasink4 = glueContext.write_dynamic_frame.from_catalog(frame=resolvechoice3, database=args["DATA_REPOSITORY_DATABASE"], table_name=args["TABLE_NAME"], transformation_ctx="datasink4")

job.commit()
