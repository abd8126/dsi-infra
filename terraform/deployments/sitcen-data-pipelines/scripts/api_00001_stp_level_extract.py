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

# Make HTTP Get request and load json response
print('Getting data')
url = secret['url']
APIKey = secret['key']
headers = {'authorization': f'Bearer {APIKey}'}
content = requests.get(url, headers=headers)

# Store reponse in S3
print('Writing data')
output_file_name = f'SitCen/stp-level-api1/{datetime.datetime.now().replace(microsecond=0).isoformat()}'
object = s3.Object(args['LANDING_BUCKET'], output_file_name)
object.put(Body=content.text)