import re
import os

{
    "type":"TOKEN",
    "authorizationToken":"allow",
    "methodArn":"arn:aws:execute-api:eu-west-2:515924272305:odftpphl05/*/POST/"
}

def lambda_handler(event, context):
    print("Client token: " + event['authorizationToken'])
    print("Method ARN: " + event['methodArn'])
    
    if event['authorizationToken'] == os.environ['token']:
        response = {
            'principalId':'user',
            'policyDocument':{"Version": "2012-10-17",
                "Statement": [
                    {
                    "Action": "execute-api:Invoke",
                    "Effect": "Allow",
                    "Resource": "*"
                    }
                ]
                
            }
        }
        return response
    response = {
        "principalId": "user",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Action": "execute-api:Invoke",
                "Effect": "Deny",
                "Resource": "*"
                }
            ]
        }
    }
    return response