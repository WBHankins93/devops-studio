# Platform API

RESTful APIs that enable programmatic access to platform capabilities.

## Overview

The Platform API provides endpoints for:
- Infrastructure provisioning
- Resource management
- CI/CD pipeline creation
- Monitoring and metrics

## API Endpoints

### Provisioning API

#### Provision Service
```http
POST /api/v1/provision
Content-Type: application/json

{
  "template": "web-app",
  "parameters": {
    "app_name": "my-app",
    "environment": "dev"
  }
}
```

**Response**:
```json
{
  "provision_id": "prov-123",
  "status": "in_progress",
  "estimated_time": "5 minutes"
}
```

#### Get Provision Status
```http
GET /api/v1/provision/{provision_id}
```

**Response**:
```json
{
  "provision_id": "prov-123",
  "status": "completed",
  "resources": {
    "alb_dns_name": "my-app-dev-alb.us-west-2.elb.amazonaws.com"
  }
}
```

### Resource Management API

#### List Resources
```http
GET /api/v1/resources?environment=dev
```

#### Get Resource Details
```http
GET /api/v1/resources/{resource_id}
```

#### Delete Resource
```http
DELETE /api/v1/resources/{resource_id}
```

### CI/CD API

#### Create Pipeline
```http
POST /api/v1/pipelines
Content-Type: application/json

{
  "service_name": "my-app",
  "repository": "github.com/org/my-app",
  "environments": ["dev", "staging", "prod"]
}
```

### Monitoring API

#### Get Metrics
```http
GET /api/v1/metrics?service=my-app&timeframe=24h
```

## Authentication

All API requests require authentication:

```http
Authorization: Bearer <api_token>
```

## Rate Limiting

- **Standard**: 100 requests/minute
- **Premium**: 1000 requests/minute

## Error Handling

All errors follow this format:

```json
{
  "error": {
    "code": "PROVISION_FAILED",
    "message": "Provisioning failed due to invalid parameters",
    "details": {...}
  }
}
```

## SDK Examples

### Python

```python
from platform_api import PlatformClient

client = PlatformClient(api_key="your-api-key")

# Provision service
result = client.provision(
    template="web-app",
    parameters={"app_name": "my-app", "environment": "dev"}
)

# Check status
status = client.get_provision_status(result.provision_id)
```

### JavaScript

```javascript
const PlatformClient = require('platform-api');

const client = new PlatformClient({ apiKey: 'your-api-key' });

// Provision service
const result = await client.provision({
  template: 'web-app',
  parameters: { app_name: 'my-app', environment: 'dev' }
});
```

