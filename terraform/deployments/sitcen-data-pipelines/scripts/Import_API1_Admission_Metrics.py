import requests
import boto3
import json
import sys
import datetime
from awsglue.utils import getResolvedOptions

args = getResolvedOptions(sys.argv, ['SECRET_ID', 'LANDING_BUCKET'])

secrets_manager = boto3.client('secretsmanager')
s3 = boto3.resource('s3')

# Get secret and load json
print('Getting secret')
secret_response = secrets_manager.get_secret_value(SecretId=args['SECRET_ID'])
secret = json.loads(secret_response['SecretString'])

url = secret['url']
token = secret['key']
headers = {'Authorization': f'Bearer {token}'}
response = requests.get(url, headers=headers)

# Store reponse in S3
print('Writing data')
output_file_name = f'sitcen/admission_metrics-api1/{datetime.datetime.now().replace(microsecond=0).isoformat()}.csv'
object = s3.Object(args['LANDING_BUCKET'], output_file_name)
object.put(Body=response.content)
