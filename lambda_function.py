import boto3
import os

def lambda_handler(event, context):
    sns_client = boto3.client('sns')
    topic_arn = os.environ['SNS_TOPIC_ARN']
    message = "Hello, world!"
    
    sns_client.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject="Daily Email Notification"
    )
    return {
        "statusCode": 200,
        "body": "Email sent successfully!"
    }
