"""
Event Processor Lambda Function
Processes events from various sources (S3, EventBridge, etc.).

This function demonstrates:
- Event-driven processing
- S3 event handling
- EventBridge event handling
- Error handling and retries
- DynamoDB integration
"""

import json
import logging
import os
import boto3
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# Get table name from environment
TABLE_NAME = os.environ.get('EVENTS_TABLE_NAME', 'events')

def lambda_handler(event, context):
    """
    Process events from various sources.
    
    Supports:
    - S3 events (file uploads)
    - EventBridge events (custom events)
    - Scheduled events (CloudWatch Events)
    """
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Determine event source
        if 'Records' in event:
            # S3 event
            return process_s3_event(event)
        elif 'source' in event:
            # EventBridge event
            return process_eventbridge_event(event)
        elif 'detail-type' in event:
            # CloudWatch Events
            return process_cloudwatch_event(event)
        else:
            # Unknown event type
            logger.warning(f"Unknown event type: {json.dumps(event)}")
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'error': 'Unknown event type',
                    'event': event
                })
            }
            
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}", exc_info=True)
        # Re-raise to trigger retry (if configured)
        raise

def process_s3_event(event):
    """Process S3 events (file uploads)."""
    processed_records = []
    
    for record in event['Records']:
        try:
            # Extract S3 event details
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']
            event_name = record['eventName']
            event_time = record['eventTime']
            
            logger.info(f"Processing S3 event: {event_name} for {bucket}/{key}")
            
            # Get object metadata
            response = s3.head_object(Bucket=bucket, Key=key)
            size = response['ContentLength']
            content_type = response.get('ContentType', 'unknown')
            
            # Store event in DynamoDB
            event_data = {
                'event_id': f"s3-{record['responseElements']['x-amz-request-id']}",
                'event_type': 's3',
                'source': bucket,
                'key': key,
                'event_name': event_name,
                'size': size,
                'content_type': content_type,
                'timestamp': event_time,
                'processed_at': datetime.utcnow().isoformat()
            }
            
            store_event(event_data)
            processed_records.append(event_data)
            
        except Exception as e:
            logger.error(f"Error processing S3 record: {str(e)}", exc_info=True)
            # Continue processing other records
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'Processed {len(processed_records)} S3 events',
            'records': processed_records
        })
    }

def process_eventbridge_event(event):
    """Process EventBridge custom events."""
    try:
        source = event.get('source', 'unknown')
        detail_type = event.get('detail-type', 'unknown')
        detail = event.get('detail', {})
        time = event.get('time', datetime.utcnow().isoformat())
        
        logger.info(f"Processing EventBridge event: {detail_type} from {source}")
        
        # Store event in DynamoDB
        event_data = {
            'event_id': event.get('id', f"eb-{context.aws_request_id}"),
            'event_type': 'eventbridge',
            'source': source,
            'detail_type': detail_type,
            'detail': detail,
            'timestamp': time,
            'processed_at': datetime.utcnow().isoformat()
        }
        
        store_event(event_data)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'EventBridge event processed',
                'event': event_data
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing EventBridge event: {str(e)}", exc_info=True)
        raise

def process_cloudwatch_event(event):
    """Process CloudWatch Events (scheduled events)."""
    try:
        source = event.get('source', 'aws.events')
        detail_type = event.get('detail-type', 'Scheduled Event')
        time = event.get('time', datetime.utcnow().isoformat())
        
        logger.info(f"Processing CloudWatch event: {detail_type}")
        
        # Store event in DynamoDB
        event_data = {
            'event_id': f"cw-{context.aws_request_id}",
            'event_type': 'cloudwatch',
            'source': source,
            'detail_type': detail_type,
            'timestamp': time,
            'processed_at': datetime.utcnow().isoformat()
        }
        
        store_event(event_data)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'CloudWatch event processed',
                'event': event_data
            })
        }
        
    except Exception as e:
        logger.error(f"Error processing CloudWatch event: {str(e)}", exc_info=True)
        raise

def store_event(event_data):
    """Store event in DynamoDB."""
    try:
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(Item=event_data)
        logger.info(f"Stored event: {event_data['event_id']}")
    except Exception as e:
        logger.error(f"Error storing event in DynamoDB: {str(e)}", exc_info=True)
        raise

