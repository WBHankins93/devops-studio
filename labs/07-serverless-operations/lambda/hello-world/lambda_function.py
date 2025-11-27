"""
Hello World Lambda Function
A simple example demonstrating basic Lambda function structure.

This function:
- Receives an event and context
- Returns a JSON response
- Demonstrates basic error handling
"""

import json
import os
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda handler function.
    
    Args:
        event: Event data passed to the function
        context: Runtime information about the Lambda execution
    
    Returns:
        dict: Response with status code and body
    """
    try:
        # Log the incoming event
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Get environment variables (if any)
        environment = os.environ.get('ENVIRONMENT', 'development')
        
        # Extract data from event (if present)
        name = event.get('name', 'World')
        message = event.get('message', 'Hello')
        
        # Build response
        response_body = {
            'message': f'{message}, {name}!',
            'environment': environment,
            'function_name': context.function_name,
            'request_id': context.aws_request_id,
            'remaining_time_ms': context.get_remaining_time_in_millis(),
            'event_received': event
        }
        
        logger.info(f"Returning response: {json.dumps(response_body)}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_body, indent=2)
        }
        
    except Exception as e:
        # Log the error
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        
        # Return error response
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }

