# Import modules
import logging
import json
import urllib3

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


# Define Lambda function
def lambda_handler(event, context):
    
    http = urllib3.PoolManager()
    link = "https://eu-west-2.console.aws.amazon.com/gluestudio/home?region=eu-west-2#/monitoring"
    message = f"A Glue Job {event['detail']['jobName']} with Job Run ID {event['detail']['jobRunId']} has entered the state {event['detail']['state']} with error message: {event['detail']['message']}. Visit the link for job monitoring {link}"
    logger.info(message)
    headers = {"Content-type": "application/json"}
    data = {"text": message}
    response = http.request("POST",
                        "https://hooks.slack.com/services/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",
                        body = json.dumps(data),
                        headers = headers,
                        retries = False)
    logger.info(response.status)
