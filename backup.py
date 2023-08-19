import json
import requests


def lambda_handler(event, context):
    # Moogsoft API endpoint
    moogsoft_api_url = "https://api.moogsoft.ai/v1/integrations/events"

    # API Key for authentication
    api_key = "6f745214-46a2-485b-a171-80aa324995ec"

    # Extract source from the event
    event_source = event['source']
    event_detail_type = event['deatil-type']
    event_state = event['detail']['state']
    instance_id = event['detail']['instance-id']

    # Request payload with updated source
    payload = {
        "description": event_detail_type,
        "severity": 4,
        "source": event_source,  # Updated with the event source
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
