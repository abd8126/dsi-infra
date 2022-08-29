import sys
import datetime
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import udf
import boto3
import json
import jsonschema
import time

args = getResolvedOptions(sys.argv, ["JOB_NAME", "LANDING_DATABASE", "DATA_REPOSITORY_DATABASE", "TABLE_NAME","LANDING_BUCKET","REPOSITORY_BUCKET"])

error_string = "error"

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

validated_landing_dyf = landing_data #Map.apply(landing_data, validate_dynamic_frame, stageThreshold=999999, totalThreshold=9999999)

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

schema = {"properties": {"statements": {"maxItems": 50, "type": "array"}}}
item_schema = {
     "properties": {
     "id": {"type": "number"},
     "issued_at": {"type": "string"},
     "pdf_url": {"type": "string"},
     "detailed_csv_url": {"type": "string"},
     "area_of_concern_url": {"type": "string"},
     "flood_risk_trend": {"type": "object"},
     "sources": {"type": "array"},
     "headline": {"type": "string"},
     "amendments": {"type": "string"},
     "future_forecast": {"type": "string"},
     "last_modified_at": {"type": "string"},
     "next_issue_due_at": {"type": "string"},
     "png_thumbnails_with_days_url": {"type": "string"},
     "risk_areas": {"type": "array"},
     "aoc_maps": {"type": "array"},
     "public_forecast": {"type": "object"},
        },
        "required": ["id"],

    }
S3_BUCKET = args["LANDING_BUCKET"]  
acquisition_id = int(datetime.datetime.now().timestamp() * 1000000)


def validate(s3, bucket_name, key):
    obj = s3.get_object(Bucket=bucket_name, Key=key)
    data_for_validation = json.loads(obj["Body"].read().decode("utf-8"))
    validator = jsonschema.Draft7Validator(schema)
    validator.validate(data_for_validation)
    #self.validator = jsonschema.Draft7Validator(schema)
    statement_validator = jsonschema.Draft7Validator(item_schema)
    for json_statement in data_for_validation["statements"]:
        statement_validator.validate(json_statement)
        
    write_to_s3(data_for_validation,acquisition_id)
        
def write_to_s3(data,acquisition_id):
        bucket = args["REPOSITORY_BUCKET"]
        s3.put_object(
            Body=json.dumps(data),
            Bucket=bucket,
            Key="SitCen/repository/met-office-flood-api3/{}.json".format(
                "z_" + str(int(time.time())),
            ),
            Metadata={"acquisition_id": str(acquisition_id)},
        )
 
S3_BUCKET = args["LANDING_BUCKET"]
#key = args["KEY"]
s3 = boto3.client("s3")
print("----------------------------------")
res=s3.list_objects_v2(Bucket=S3_BUCKET,Prefix='SitCen/met-office-flood-api3')
#print(res)
files_list = []
for file in res['Contents']:
    # print(file['Key'])
    files_list.append(file['Key'])

files_list.sort()
print(files_list[-1])
print("----------------------------------")
key = files_list[-1]

validate(s3, S3_BUCKET, key)


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
