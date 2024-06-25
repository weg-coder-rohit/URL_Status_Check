import json
import urllib.request
import boto3
import os

sns_client = boto3.client('sns')


def lambda_handler(event, context):
    # TODO implement

    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    
    url = event['key1']
    try:
        # Attempt to open the URL and get the HTTP status code
        status_code = urllib.request.urlopen(url).getcode()
        if status_code != 200:
            # IF our URL is down, send SNS notification
            message = f"URL {url} is down! Status code: {status_code}"
            # send_sms(message)
            sns_client.publish(
                TopicArn=sns_topic_arn,
                Message=message,
                Subject=f"Alert: URL {url} is down!"
            )
        return {
            'statusCode': status_code,
            'body': f'Status of {url} is: {status_code}'
        }
    except Exception as e:
        # Handle any potential exceptions, e.g., URL not accessible, connection timeout Used because CG has blocked access to some websites
        error_message = f"Error checking {url}: {str(e)}"
        # send_sms(error_message)
        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=error_message,
            Subject=f"Error: {error_message}"
        )
        return {
            'statusCode': 500,
            'body': f'Error checking {url}: {str(e)}'
        }
