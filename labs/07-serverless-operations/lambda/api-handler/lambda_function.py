"""
API Handler Lambda Function
Handles HTTP requests from API Gateway.

This function demonstrates:
- API Gateway integration
- Request parsing
- Response formatting
- Error handling
- CORS support
"""

import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Handle API Gateway requests.
    
    API Gateway event structure:
    {
        "httpMethod": "GET|POST|PUT|DELETE",
        "path": "/path",
        "headers": {...},
        "queryStringParameters": {...},
        "pathParameters": {...},
        "body": "..."
    }
    """
    try:
        # Extract HTTP method
        http_method = event.get('httpMethod', 'GET')
        path = event.get('path', '/')
        
        logger.info(f"Received {http_method} request to {path}")
        
        # Parse query parameters
        query_params = event.get('queryStringParameters') or {}
        
        # Parse path parameters
        path_params = event.get('pathParameters') or {}
        
        # Parse request body (if present)
        body = {}
        if event.get('body'):
            try:
                body = json.loads(event['body'])
            except json.JSONDecodeError:
                body = {'raw': event['body']}
        
        # Route based on HTTP method and path
        if http_method == 'GET':
            response_data = handle_get(path, query_params, path_params)
        elif http_method == 'POST':
            response_data = handle_post(path, body, path_params)
        elif http_method == 'PUT':
            response_data = handle_put(path, body, path_params)
        elif http_method == 'DELETE':
            response_data = handle_delete(path, path_params)
        else:
            response_data = {
                'error': 'Method not allowed',
                'method': http_method
            }
        
        # Build response
        return {
            'statusCode': response_data.get('statusCode', 200),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
            },
            'body': json.dumps(response_data.get('body', response_data), indent=2)
        }
        
    except Exception as e:
        logger.error(f"Error handling request: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }

def handle_get(path, query_params, path_params):
    """Handle GET requests."""
    from datetime import datetime
    return {
        'statusCode': 200,
        'body': {
            'message': 'GET request successful',
            'path': path,
            'query_params': query_params,
            'path_params': path_params,
            'timestamp': datetime.utcnow().isoformat()
        }
    }

def handle_post(path, body, path_params):
    """Handle POST requests."""
    return {
        'statusCode': 201,
        'body': {
            'message': 'POST request successful',
            'path': path,
            'data_received': body,
            'path_params': path_params
        }
    }

def handle_put(path, body, path_params):
    """Handle PUT requests."""
    return {
        'statusCode': 200,
        'body': {
            'message': 'PUT request successful',
            'path': path,
            'data_received': body,
            'path_params': path_params
        }
    }

def handle_delete(path, path_params):
    """Handle DELETE requests."""
    return {
        'statusCode': 200,
        'body': {
            'message': 'DELETE request successful',
            'path': path,
            'path_params': path_params
        }
    }

