import sys
import datetime
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import udf

args = getResolvedOptions(sys.argv, ["JOB_NAME", "LANDING_DATABASE", "DATA_REPOSITORY_DATABASE", "TABLE_NAME"])

error_string = "error"


def transform_date(date):
    validated_date = str(datetime.datetime.strptime(
        date.split()[0], "%Y-%m-%d").date())
    return validated_date


def validate_dynamic_frame(rec):
    rec["border_flow_indicator_id"] = rec["border_flow_indicator_id"] if rec["border_flow_indicator_id"].startswith(
        "flow_") else error_string

    # rec["observation_date"] = transform_date(rec["observation_date"])
    return rec


sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
logger = glueContext.get_logger()
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# @type: DataSource
# @args: [database = args["LANDING_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "landing_data"]
# @return: landing_data
# @inputs: []
landing_data = glueContext.create_dynamic_frame.from_catalog(
    database=args["LANDING_DATABASE"], table_name=args["TABLE_NAME"], transformation_ctx="landing_data")

validated_landing_dyf = Map.apply(landing_data, validate_dynamic_frame, stageThreshold=999999, totalThreshold=9999999)

# @type: ResolveChoice
# @args: [choice = "MATCH_CATALOG", database = "dsi-data-repository", table_name = args["TABLE_NAME"], transformation_ctx = "match_catalog"]
# @return: resolvechoice
# @inputs: [frame = validated_landing_data]
resolvechoice = ResolveChoice.apply(frame=validated_landing_dyf, choice="MATCH_CATALOG",
                                    database=args["DATA_REPOSITORY_DATABASE"], table_name=args["TABLE_NAME"], transformation_ctx="resolvechoice")


# @type: DataSource
# @args: [database = args["DATA_REPOSITORY_DATABASE"], table_name = args["TABLE_NAME"]]
# @return: data_repository_data
# @inputs: []
repository_dyf = glueContext.create_dynamic_frame.from_catalog(
    database=args["DATA_REPOSITORY_DATABASE"], table_name=args["TABLE_NAME"])

# Get row counts for data in the repository
# Get row counts for new files in landing bucket
existing_row_count = repository_dyf.count()
validated_row_count = resolvechoice.count()


if validated_row_count == 0:
    logger.info('No landing data ingested. Job complete.')

else:
    if repository_dyf.count() == 0:
        new_data_dyf = resolvechoice
    else:
        landing_df = resolvechoice.toDF()
        repository_df = repository_dyf.toDF()
        new_data_df = landing_df.subtract(repository_df)  # remove rows which already exist in the repository
        new_data_dyf = DynamicFrame.fromDF(new_data_df, glueContext, "new_data_dyf")

    new_data_row_count = new_data_dyf.count()

    # @type: DataSink
    # @args: [database = args["DATA_REPOSITORY_DATABASE"], table_name=args["TABLE_NAME"], transformation_ctx = "datasink"]
    # @return: datasink
    # @inputs: [frame = landing_data]
    if new_data_row_count > 0:
        datasink = glueContext.write_dynamic_frame.from_catalog(
            frame=new_data_dyf,
            database=args["DATA_REPOSITORY_DATABASE"],
            table_name=args["TABLE_NAME"],
            transformation_ctx="datasink"
        )

    logger.warn(
        f"""output_table: {args['TABLE_NAME']}\n
        existing_rows_in_repository: {existing_row_count}\n
        validated_rows_ingested_from_landing: {validated_row_count}\n
        new_distinct_rows: {new_data_row_count}\n
        total_rows_in_repository: {existing_row_count + new_data_row_count}""")

job.commit()
