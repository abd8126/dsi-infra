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

validated_landing_dyf = landing_data

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


schema = {
  "properties": {
    "offset": {"type": "integer"},
    "limit": { "type": "integer"},
    "totalItems": {"type": "integer" },
     "items": {"type": "array"}
      },
      "required": [
      "offset",
      "limit",
      "totalItems",
      "items"
  ]
      
      }

item_schema =   {
          "properties": {
            "cqcId_test": {"type": "string" },
            "odsCode": {"type": "string"},
            "ccgOdsCode": {"type": "string" },
            "laSnacCode": {"type": "string"},
            "vacanciesLastUpdated": {"type": "string"},
            "isCareHome": {"type": "boolean"},
            "isAcute": {"type": "boolean"},
            "isCommunity": {"type": "boolean"},
            "isHospice": {"type": "boolean"},
            "isSubstanceMisuse": {"type": "boolean"},
            "homePressure": {"type": "integer"},
            "vacancies": {"type": "array"}
              },
          "required": [
            "cqcId",
            "odsCode",
            "ccgOdsCode",
            "laSnacCode",
            "vacanciesLastUpdated",
            "isCareHome",
            "isAcute",
            "isCommunity",
            "isHospice",
            "isSubstanceMisuse",
            "admissionStatus",
            "homePressure",
            "vacancies"
           ]
  }

S3_BUCKET = args["LANDING_BUCKET"]   
acquisition_id = int(datetime.datetime.now().timestamp() * 1000000)


def validate(s3, bucket_name, key):
    obj = s3.get_object(Bucket=bucket_name, Key=key)
    data_for_validation = json.loads(obj["Body"].read().decode("utf-8"))
    validator = jsonschema.Draft7Validator(schema)
    validator.validate(data_for_validation)
    
    item_schema_validator = jsonschema.Draft7Validator(item_schema)
    
    for json_statement in data_for_validation["items"]:
        print(json_statement)
        item_schema_validator.validate(json_statement)
        
        '''
        vacancies_validator = jsonschema.Draft7Validator(vacancies_schema)
        for vacancies in json_statement["vacancies"]:
            vacanies_validator.validate(vacancies)
        property_validator.validate(json_statement["properties"])
    '''
    write_to_s3(data_for_validation,acquisition_id)

def write_to_s3(data,acquisition_id):
        bucket = args["REPOSITORY_BUCKET"]
        s3.put_object(
            Body=json.dumps(data),
            Bucket=bucket,
            Key="SitCen/repository/cqc-social-care-daily-details-api6/{}.json".format(
                "z_" + str(int(time.time())),
            ),
            Metadata={"acquisition_id": str(acquisition_id)},
        )
 
S3_BUCKET = args["LANDING_BUCKET"]

s3 = boto3.client("s3")
print("----------------------------------")
res=s3.list_objects_v2(Bucket=S3_BUCKET,Prefix='SitCen/repository/cqc-social-care-daily-details-api6')
files_list = []
for file in res['Contents']:
    
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
