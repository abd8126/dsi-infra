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

location_types =["Region", "Country"]

location_names=["London",
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
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("location_type", "string", "location_type", "string"), ("location_name", "string", "location_name", "string"), ("date", "string", "date", "string"), ("metric_name", "string", "metric_name", "string"), ("metric_value", "string", "metric_value", "string"), ("unit", "double", "unit", "double")], transformation_ctx = "applymapping1")
## @type: SelectFields
## @args: [paths = ["location_type", "location_name", "date", "metric_name", "metric_value", "unit"], transformation_ctx = "selectfields2"]
## @return: selectfields2
## @inputs: [frame = applymapping1]
selectfields2 = SelectFields.apply(frame = applymapping1, paths = ["location_type", "location_name", "date", "metric_name", "metric_value", "unit"], transformation_ctx = "selectfields2")
## @type: ResolveChoice
## @args: [choice = "MATCH_CATALOG", database = args["DATA_REPOSITORY_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "resolvechoice3"]
## @return: resolvechoice3
## @inputs: [frame = selectfields2]
resolvechoice3 = ResolveChoice.apply(frame = selectfields2, choice = "MATCH_CATALOG", database = args["DATA_REPOSITORY_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "resolvechoice3")
## @type: DataSink
## @args: [database = args["DATA_REPOSITORY_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "datasink4"]
## @return: datasink4
## @inputs: [frame = resolvechoice3]

val_spark_df=resolvechoice3.toDF()

val_out_spark_df1 = val_spark_df.withColumn('location_type_good',when(col("location_type").isin(*location_types), val_spark_df.location_type).otherwise("Unknown"))

val_out_spark_df2 = val_out_spark_df1.withColumn('location_name_good',when(col("location_name").isin(*location_names), val_spark_df.location_name).otherwise("Unknown"))

logger.info("Create dataframe of errors")
val_out_spark_errors = val_out_spark_df2.filter(f'location_type_good="Unknown" or location_name_good="Unknown"')

error_count=(val_out_spark_errors.count())
logger.info("Errors: {}".format(error_count))

val_out_spark_dyf = DynamicFrame.fromDF(val_out_spark_df2, glueContext, 'val_out_spark_dyf')

if error_count == 0:
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

logger.info("Logging==========")