# Lambda Functions

This directory contains Lambda function examples demonstrating various serverless patterns.

## Functions

### hello-world
A simple "Hello World" function demonstrating basic Lambda concepts.

**Key Features**:
- Basic event handling
- Logging
- Error handling
- Environment variables

**Use Case**: Learning Lambda basics

### api-handler
An API handler that processes HTTP requests from API Gateway.

**Key Features**:
- API Gateway integration
- HTTP method routing (GET, POST, PUT, DELETE)
- Request parsing
- CORS support

**Use Case**: RESTful API backends

### event-processor
Processes events from various sources (S3, EventBridge, CloudWatch).

**Key Features**:
- Multi-source event handling
- S3 event processing
- EventBridge integration
- DynamoDB storage

**Use Case**: Event-driven processing

## Deployment

All functions are deployed via Terraform. See `main.tf` for configuration.

## Testing

### Local Testing

```bash
# Test hello-world
cd lambda/hello-world
python -c "from lambda_function import lambda_handler; print(lambda_handler({}, None))"
```

### AWS Testing

```bash
# Invoke function
aws lambda invoke \
  --function-name function-name \
  --payload '{"key": "value"}' \
  response.json

# View response
cat response.json
```

## Best Practices

1. **Error Handling**: Always wrap code in try/except
2. **Logging**: Use structured logging
3. **Environment Variables**: Use for configuration
4. **Idempotency**: Make functions safely retryable
5. **Timeouts**: Set appropriate timeout values
6. **Memory**: Right-size memory allocation

## Monitoring

View logs in CloudWatch:
```bash
aws logs tail /aws/lambda/function-name --follow
```

