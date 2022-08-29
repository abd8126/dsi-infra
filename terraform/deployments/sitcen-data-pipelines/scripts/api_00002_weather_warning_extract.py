import requests
import boto3
import json
import sys
import datetime
import time
from awsglue.utils import getResolvedOptions
import urllib.request
import base64
from botocore.exceptions import ClientError
import xml.etree.ElementTree as ET

args = getResolvedOptions(sys.argv, ['SECRET_ID', 'LANDING_BUCKET'])


secrets_manager = boto3.client('secretsmanager')
s3 = boto3.resource('s3')

# Get secret and load json
print('Getting secret')
secret_response = secrets_manager.get_secret_value(SecretId=args["SECRET_ID"])
secret = json.loads(secret_response['SecretString'])

# Make HTTP Get request and load json response
print('Getting data')
url = secret['url']
APIKey = secret['key']
headers = { 'X-API-Key': APIKey}
response = requests.get(url, headers=headers)
print(response)

#Return todays url and store response in S3
output = response.content
tree = ET.fromstring(output)

related_links = tree.findall('{http://www.w3.org/2005/Atom}link[@rel="related"]')
assert len(related_links) == 1, 'related links are not exactly one'
url_today = related_links[0].attrib['href']
response_today = requests.get(url_today, headers=headers)
  
print('Writing data')
date = time.strftime("%Y%m%d%H%M%S")
output_file_name = f'SitCen/weather-warning-api2/{datetime.datetime.now().replace(microsecond=0).isoformat()}.json'
object = s3.Object(args['LANDING_BUCKET'], output_file_name)
object.put(Body=response_today.content)