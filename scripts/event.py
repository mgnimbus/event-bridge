import requests
import os
import json


def lambda_handler(event, context):
    # Moogsoft API endpoint
    moogsoft_api_url = os.environ.get('moogsoft_url')

    # API Key for authentication
    api_key = os.environ.get('moogsoft_api_key')

    # Extract source from the event
    event_source = event['source']
    event_detail_type = event['detail-type']
    event_state = event['detail']['state']
    instance_id = event['detail']['instance-id']

    # Request payload with updated source
    payload = {
        "description": event_detail_type,
        "type": "event",
        "severity": 2,
        "source": event_source,
        "check": event_state,
        "service": ["EC2"],
        "tags": {
            "instance-id": instance_id
        }
    }

    # Headers
    headers = {
        "Content-Type": "application/json",
        "apiKey": api_key
    }

    try:
        # Send the POST request to Moogsoft API
        response = requests.post(
            moogsoft_api_url, json=payload, headers=headers)
        response_data = response.json()

        # Process the response data as needed
        print("Response:", response_data)

        return {
            "statusCode": response.status_code,
            "body": json.dumps(response_data)
        }
    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "An error occurred"})
        }
