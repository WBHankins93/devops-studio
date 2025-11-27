# API Gateway Configuration

This module configures API Gateway to expose Lambda functions as REST APIs.

## Overview

The API Gateway configuration includes:
- REST API setup
- Lambda integration
- CORS configuration
- CloudWatch logging
- Stage deployment

## Architecture

```
Client → API Gateway → Lambda Function → Response
```

## Configuration

The API Gateway is configured to:
- Accept all HTTP methods (GET, POST, PUT, DELETE, etc.)
- Route all paths to the Lambda function
- Enable CORS for browser access
- Log requests to CloudWatch

## Testing

### Using curl

```bash
# Get API URL from outputs
API_URL=$(terraform output -raw api_gateway_url)

# Test GET request
curl $API_URL/test

# Test POST request
curl -X POST $API_URL/test \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
```

### Using AWS CLI

```bash
# Get API ID
API_ID=$(terraform output -raw api_id)

# Test API
aws apigateway test-invoke-method \
  --rest-api-id $API_ID \
  --resource-id <resource-id> \
  --http-method GET
```

## Monitoring

View API Gateway logs:
```bash
aws logs tail /aws/apigateway/devops-studio-dev-api --follow
```

## Best Practices

1. **Use Stages** - Separate dev, staging, prod
2. **Enable Logging** - Monitor API usage
3. **Set Throttling** - Prevent abuse
4. **Use API Keys** - For authentication (if needed)
5. **Enable CORS** - For browser access

