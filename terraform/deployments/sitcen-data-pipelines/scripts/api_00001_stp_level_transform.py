import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import *


## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ["JOB_NAME", "LANDING_DATABASE", "DATA_REPOSITORY_DATABASE", "TABLE_NAME"])
unknown_string='Unknown'

region_name=["Midlands",
                        "South West",
                        "East of England",
                        "London",
                        "North East and Yorkshire",
                        "North West",
                        "South East"]


sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
logger = glueContext.get_logger()
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
logger.info("Logging==========")

## @type: DataSource
## @args: [database = "devl-dops-euw2-sitcen-publish-glue-database", table_name = "api_1_stp_level", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = args["LANDING_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "datasource0")
## @type: ApplyMapping
## @args: [mapping = [("stp_code", "string", "stp_code", "string"), ("date", "string", "date", "string"), ("confirmed_covid_discharges", "string", "confirmed_covid_discharges", "string"), ("emergency_admissions_a&es", "string", "emergency_admissions_a&es", "string"), ("stp_name", "string", "stp_name", "string"), ("nhs_region_id", "string", "nhs_region_id", "string"), ("nhs_region_name", "string", "nhs_region_name", "string")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("stp_code", "string", "stp_code", "string"), ("date", "string", "date", "string"), ("confirmed_covid_discharges", "double", "confirmed_covid_discharges", "double"), ("emergency_admissions_a&es", "double", "emergency_admissions_a&es", "double"), ("stp_name", "string", "stp_name", "string"), ("nhs_region_id", "string", "nhs_region_id", "string"), ("nhs_region_name", "string", "nhs_region_name", "string")], transformation_ctx = "applymapping1")
## @type: SelectFields
## @args: [paths = ["stp_code", "date", "confirmed_covid_discharges", "emergency_admissions_a&es", "stp_name", "nhs_region_id", "nhs_region_name"], transformation_ctx = "selectfields2"]
## @return: selectfields2
## @inputs: [frame = applymapping1]
selectfields2 = SelectFields.apply(frame = applymapping1, paths = ["stp_code", "date", "confirmed_covid_discharges", "emergency_admissions_a&es", "stp_name", "nhs_region_id", "nhs_region_name"], transformation_ctx = "selectfields2")
## @type: ResolveChoice
## @args: [choice = "MATCH_CATALOG", database = "devl-dops-euw2-sitcen-publish-glue-database", table_name = "api_1_stp_level", transformation_ctx = "resolvechoice3"]
## @return: resolvechoice3
## @inputs: [frame = selectfields2]

resolvechoice3 = ResolveChoice.apply(frame = selectfields2, choice = "MATCH_CATALOG", database = args["DATA_REPOSITORY_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "resolvechoice3")
## @type: DataSink
## @args: [database = "devl-dops-euw2-sitcen-publish-glue-database", table_name = "api_1_stp_level", transformation_ctx = "datasink4"]
## @return: datasink4
## @inputs: [frame = resolvechoice3]

val_spark_df=resolvechoice3.toDF()

val_out_spark_df = val_spark_df.withColumn('region_id_good', when(col("nhs_region_name").isin(*region_name), val_spark_df.nhs_region_name).otherwise("Unknown"))

logger.info("Dataframe consists of {} entries".format((val_out_spark_df.count())))

logger.info("Create dataframe of errors")

val_out_spark_errors = val_out_spark_df[(val_out_spark_df['region_id_good']=="Unknown")]

errors_count = (val_out_spark_errors.count())
logger.info("Errors: {}".format(errors_count))


val_df = DynamicFrame.fromDF(val_out_spark_df, glueContext,"val_df")

if errors_count == 0:
    datasink4 = glueContext.write_dynamic_frame.from_catalog(
        frame=val_df,
        database = args["DATA_REPOSITORY_DATABASE"],
        table_name = args["TABLE_NAME"], 
        transformation_ctx = "datasink4"
    )
    logger.info("Data moved to data repository")
else:
    logger.info("Errors found, data not placed in data repository")

job.commit()

logger.info("End logging==========")