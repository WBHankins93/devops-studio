"""
Provisioning API Lambda Function
Handles infrastructure provisioning requests.
"""

import json
import boto3
import os
from typing import Dict, Any

ssm = boto3.client('ssm')
lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    """Handle provisioning API requests."""
    try:
        http_method = event.get('httpMethod', 'POST')
        path = event.get('path', '/')
        
        if http_method == 'POST' and path == '/api/v1/provision':
            return handle_provision(event)
        elif http_method == 'GET' and path.startswith('/api/v1/provision/'):
            provision_id = path.split('/')[-1]
            return handle_get_provision_status(provision_id)
        else:
            return {
                'statusCode': 404,
                'body': json.dumps({'error': 'Not found'})
            }
            
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def handle_provision(event: Dict[str, Any]) -> Dict[str, Any]:
    """Handle provision request."""
    body = json.loads(event.get('body', '{}'))
    
    template = body.get('template')
    workspace = body.get('workspace')
    parameters = body.get('parameters', {})
    
    if not template or not workspace:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing required fields: template, workspace'})
        }
    
    # Get platform configuration
    config_param = os.environ.get('PLATFORM_CONFIG_PARAM', '/platform/devops-studio/dev/config')
    config_response = ssm.get_parameter(Name=config_param)
    config = json.loads(config_response['Parameter']['Value'])
    
    # Invoke Terraform runner (would be another Lambda or Step Function)
    # For now, return a provision ID
    provision_id = f"prov-{workspace}-{context.aws_request_id[:8]}"
    
    # Store provision request in DynamoDB or SQS for async processing
    # For this example, we'll return immediately
    
    return {
        'statusCode': 202,
        'headers': {
            'Content-Type': 'application/json',
            'Location': f'/api/v1/provision/{provision_id}'
        },
        'body': json.dumps({
            'provision_id': provision_id,
            'status': 'in_progress',
            'workspace': workspace,
            'estimated_time': '5 minutes'
        })
    }

def handle_get_provision_status(provision_id: str) -> Dict[str, Any]:
    """Get provisioning status."""
    # In a real implementation, this would query DynamoDB or check Terraform state
    # For this example, return a mock status
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'provision_id': provision_id,
            'status': 'completed',
            'resources': {
                'alb_dns_name': 'example-alb.us-west-2.elb.amazonaws.com'
            }
        })
    }

