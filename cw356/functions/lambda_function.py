import boto3
import base64
import json

def handler(event, context):
    client = boto3.client('s3')
    bucket_name ='all-dev-tenant-bucket'
    file_name= event['pathParameters']['proxy']

    print(f"Bucket name: {bucket_name}")
    print(f"File name: {file_name}")
   
    
    fileObject = client.get_object(Bucket=bucket_name, Key=file_name)
    
    print("Object retrieved from s3")

    file_content = fileObject["Body"].read()
    
    print(bucket_name, file_name)
    
    return {
      "isBase64Encoded": True,
      "statusCode": 200,
      "headers": { "content-type": "application/json"},
      "body":  json.dumps({"content":base64.b64encode(file_content).decode("utf-8")})
    }
