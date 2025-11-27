# DynamoDB Configuration

This document explains the DynamoDB table configuration for the serverless lab.

## Overview

DynamoDB is a fully managed NoSQL database service that provides:
- Single-digit millisecond latency
- Automatic scaling
- Built-in security
- Global tables

## Table Configuration

### Events Table

**Table Name**: `{project-name}-{environment}-events`

**Primary Key**:
- `event_id` (String) - Hash key

**Global Secondary Index**:
- `timestamp-index` - Hash key: `timestamp`

**Billing Mode**: PAY_PER_REQUEST (On-demand)

**Features**:
- Point-in-time recovery enabled
- Encryption at rest
- Auto-scaling

## Data Model

```json
{
  "event_id": "s3-abc123",
  "event_type": "s3",
  "source": "my-bucket",
  "key": "path/to/file.txt",
  "event_name": "ObjectCreated:Put",
  "size": 1024,
  "content_type": "text/plain",
  "timestamp": "2024-01-01T00:00:00Z",
  "processed_at": "2024-01-01T00:00:01Z"
}
```

## Usage

### Put Item

```python
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('devops-studio-dev-events')

table.put_item(
    Item={
        'event_id': 'test-123',
        'event_type': 'test',
        'timestamp': '2024-01-01T00:00:00Z'
    }
)
```

### Query by Event ID

```python
response = table.get_item(
    Key={'event_id': 'test-123'}
)
```

### Query by Timestamp (GSI)

```python
response = table.query(
    IndexName='timestamp-index',
    KeyConditionExpression='timestamp = :ts',
    ExpressionAttributeValues={
        ':ts': '2024-01-01T00:00:00Z'
    }
)
```

## Best Practices

1. **Partition Keys** - Choose high-cardinality keys
2. **GSI** - Use for different query patterns
3. **On-Demand** - Use for variable workloads
4. **Point-in-Time Recovery** - Enable for production
5. **Monitoring** - Monitor read/write capacity

## Cost Optimization

- Use on-demand billing for variable workloads
- Right-size read/write capacity (if using provisioned)
- Use DynamoDB Streams for change capture
- Enable auto-scaling (if using provisioned)

