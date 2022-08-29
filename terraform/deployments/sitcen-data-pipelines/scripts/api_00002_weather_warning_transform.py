import sys
import datetime
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql.functions import udf
import logging
from logging.handlers import RotatingFileHandler
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
job.init(args['JOB_NAME'], args)
logger.info("Logging==========")



## @type: DataSource
## @args: [database = "dsi-landing", table_name = "api_00002_weather_warning", transformation_ctx = "landing_data"]
## @return: landing_data
## @inputs: []
landing_data = glueContext.create_dynamic_frame.from_catalog(database = args["LANDING_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "landing_data")
## @type: ApplyMapping
## @args: [mapping = [("type", "string", "type", "string"), ("features", "array", "features", "array")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = landing_data]
applymapping1 = ApplyMapping.apply(frame = landing_data, mappings = [("type", "string", "type", "string"), ("features", "array", "features", "array")], transformation_ctx = "applymapping1")
## @type: SelectFields
## @args: [paths = ["type", "features"], transformation_ctx = "selectfields2"]
## @return: selectfields2
## @inputs: [frame = applymapping1]
selectfields2 = SelectFields.apply(frame = applymapping1, paths = ["type", "features"], transformation_ctx = "selectfields2")
## @type: ResolveChoice
## @args: [choice = "MATCH_CATALOG", database = "dsi-data-repository", table_name = "api_00002_weather_warning", transformation_ctx = "resolvechoice3"]
## @return: resolvechoice3
## @inputs: [frame = selectfields2]
resolvechoice3 = ResolveChoice.apply(frame = selectfields2, choice = "MATCH_CATALOG", database = args["DATA_REPOSITORY_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "resolvechoice3")
## @type: DataSink
## @args: [database = "dsi-data-repository", table_name = "api_00002_weather_warning", transformation_ctx = "datasink4"]
## @return: datasink4
## @inputs: [frame = resolvechoice3]
datasink4 = glueContext.write_dynamic_frame.from_catalog(frame = resolvechoice3, database = args["DATA_REPOSITORY_DATABASE"], table_name = args["TABLE_NAME"], transformation_ctx = "datasink4")


response_structure_json_schema = {
    "type": "object",
    "properties": {"type": {"type": "string"}, "features": {"type": "array"}},
    "required": ["features"],
}
feature_structure_json_validation = {
    "type": "object",
    "properties": {"type": {"type": "string"}, "properties": {"type": "object"}},
    "required": ["properties"],
}
properties_structure_json_schema = {
    "type": "object",
    "properties": {
        "warningId": {"type": "string"},
        "warningVersion": {"type": "string"},
        "warningLevel": {"type": "string"},
        "warningImpact": {"type": "number"},
        "warningLikelihood": {"type": "number"},
        "issuedDate": {"type": "string"},
        "warningStatus": {"type": "string"},
        "warningHeadline": {"type": "string"},
        "affectedAreas": {"type": "array"},
        "warningFurtherDetails": {"type": "string"},
        "whatToExpect": {"anyOf": [{"type": "string"}, {"type": "array"}]},
        "validFromDate": {"type": "string"},
        "validToDate": {"type": "string"},
        "weatherType": {"type": "array"},
    },
    "required": [
        "warningId",
        "warningVersion",
        "warningLevel",
        "warningImpact",
        "warningLikelihood",
        "issuedDate",
        "warningStatus",
        "warningHeadline",
        "affectedAreas",
        "warningFurtherDetails",
        "whatToExpect",
        "validFromDate",
        "validToDate",
        "weatherType",
    ],
}

S3_BUCKET = args["LANDING_BUCKET"]  
acquisition_id = int(datetime.datetime.now().timestamp() * 1000000)


def validate(s3, bucket_name, key):
    obj = s3.get_object(Bucket=bucket_name, Key=key)
    data_for_validation = json.loads(obj["Body"].read().decode("utf-8"))
    validator = jsonschema.Draft7Validator(response_structure_json_schema)
    validator.validate(data_for_validation)
    
    feature_validator = jsonschema.Draft7Validator(feature_structure_json_validation)
    property_validator = jsonschema.Draft7Validator(properties_structure_json_schema)
    
    print("test statement")
    for json_statement in data_for_validation["features"]:
        print(json_statement)
        feature_validator.validate(json_statement)
        
        property_validator.validate(json_statement)
        
        
    write_to_s3(data_for_validation,acquisition_id)
        
def write_to_s3(data,acquisition_id):
        bucket = args["REPOSITORY_BUCKET"]
        s3.put_object(
            Body=json.dumps(data),
            Bucket=bucket,
            Key="SitCen/repository/weather-warning-api2/{}.json".format(
                "z_" + str(int(time.time())),
            ),
            Metadata={"acquisition_id": str(acquisition_id)},
        )
 
S3_BUCKET = args["LANDING_BUCKET"]
#key = args["KEY"]
s3 = boto3.client("s3")
print("----------------------------------")
res=s3.list_objects_v2(Bucket=S3_BUCKET,Prefix='SitCen/weather-warning-api2')
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
existing_row_count = datasink4.count()
validated_row_count = resolvechoice3.count()

if validated_row_count == 0:
    logger.info('No landing data ingested. Job complete.')
	
else:
    if datasink4.count() == 0:
        new_data_dyf = resolvechoice3
    else:
        landing_df = resolvechoice3.toDF()
        datasink4 = datasink4.toDF()
        new_data_df = landing_df.subtract(datasink4)  # remove rows which already exist in the repository
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
