import boto3
import json
import time
import requests
from requests.structures import CaseInsensitiveDict
import sys
from awsglue.utils import getResolvedOptions
import datetime


args = getResolvedOptions(sys.argv, ['SECRET_ID', 'LANDING_BUCKET'])

session = boto3.session.Session()
client = session.client(
    service_name='secretsmanager'
)

get_secret_value_response = client.get_secret_value(SecretId=args["SECRET_ID"])
dict = json.loads(get_secret_value_response['SecretString'])

token = dict['key']
url = dict['url']
headers = CaseInsensitiveDict()
headers["Authorization"] = "Bearer " + token
print("API Deaths")
print(headers)
res = requests.get(url, headers=headers)
print(res.status_code)
if not res.ok:
    raise RuntimeError(f"Failure... {res.status_code}")    
date = time.strftime("%Y%m%d%H%M%S")
file_name = f'SitCen/deaths-api1/{datetime.datetime.now().replace(microsecond=0).isoformat()}.csv'
s3 = boto3.resource('s3')
object = s3.Object(args['LANDING_BUCKET'], file_name)
object.put(Body=res.content)
