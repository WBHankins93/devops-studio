"""
Monitoring API Lambda Function
Handles monitoring and metrics requests.
"""

import json
import boto3
from datetime import datetime, timedelta
from typing import Dict, Any

cloudwatch = boto3.client('cloudwatch')

def lambda_handler(event, context):
    """Handle monitoring API requests."""
    try:
        http_method = event.get('httpMethod', 'GET')
        path = event.get('path', '/')
        query_params = event.get('queryStringParameters') or {}
        
        if http_method == 'GET' and path == '/api/v1/metrics':
            return handle_get_metrics(query_params)
        elif http_method == 'GET' and path.startswith('/api/v1/services/'):
            service_name = path.split('/')[-2] if path.endswith('/metrics') else path.split('/')[-1]
            return handle_get_service_metrics(service_name, query_params)
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

def handle_get_metrics(query_params: Dict[str, Any]) -> Dict[str, Any]:
    """Get platform metrics."""
    metric_name = query_params.get('metric', 'Platform.Provisioning.Success')
    timeframe = query_params.get('timeframe', '24h')
    
    # Calculate time range
    end_time = datetime.utcnow()
    if timeframe == '1h':
        start_time = end_time - timedelta(hours=1)
        period = 300  # 5 minutes
    elif timeframe == '24h':
        start_time = end_time - timedelta(hours=24)
        period = 3600  # 1 hour
    elif timeframe == '7d':
        start_time = end_time - timedelta(days=7)
        period = 86400  # 1 day
    else:
        start_time = end_time - timedelta(days=30)
        period = 86400
    
    # Get metric statistics
    response = cloudwatch.get_metric_statistics(
        Namespace='Platform',
        MetricName=metric_name,
        StartTime=start_time,
        EndTime=end_time,
        Period=period,
        Statistics=['Sum', 'Average']
    )
    
    metrics = []
    for datapoint in response['Datapoints']:
        metrics.append({
            'value': datapoint['Sum'] if 'Sum' in datapoint else datapoint['Average'],
            'timestamp': datapoint['Timestamp'].isoformat()
        })
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'metric': metric_name,
            'timeframe': timeframe,
            'metrics': sorted(metrics, key=lambda x: x['timestamp'])
        })
    }

def handle_get_service_metrics(service_name: str, query_params: Dict[str, Any]) -> Dict[str, Any]:
    """Get metrics for a specific service."""
    # In a real implementation, this would query service-specific metrics
    # For this example, return mock data
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'service': service_name,
            'metrics': {
                'cpu_utilization': 45.2,
                'memory_utilization': 62.1,
                'request_count': 1250,
                'error_rate': 0.02
            },
            'timestamp': datetime.utcnow().isoformat()
        })
    }

