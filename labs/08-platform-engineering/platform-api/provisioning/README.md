# Provisioning API

API endpoints for infrastructure provisioning.

## Endpoints

### POST /api/v1/provision

Provision a new service from a template.

**Request**:
```json
{
  "template": "web-app",
  "workspace": "my-app-dev",
  "parameters": {
    "app_name": "my-app",
    "environment": "dev",
    "instance_type": "t3.medium"
  }
}
```

**Response**:
```json
{
  "provision_id": "prov-123",
  "status": "in_progress",
  "workspace": "my-app-dev",
  "estimated_time": "5 minutes"
}
```

### GET /api/v1/provision/{provision_id}

Get provisioning status.

**Response**:
```json
{
  "provision_id": "prov-123",
  "status": "completed",
  "workspace": "my-app-dev",
  "resources": {
    "alb_dns_name": "my-app-dev-alb.us-west-2.elb.amazonaws.com"
  }
}
```

## Implementation

This would be implemented as:
- Lambda function with API Gateway
- Express.js API (if using containers)
- Python Flask/FastAPI service

## Example Implementation

See example implementations in:
- `lambda/` - Lambda function example
- `express/` - Express.js example
- `python/` - Python FastAPI example

