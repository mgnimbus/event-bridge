import json
import requests


def lambda_handler(event, context):
    print('Lambda function is triggered')
    print('Event Detail:', json.dumps(event))
