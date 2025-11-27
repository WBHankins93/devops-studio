# Hello World Lambda Function

A simple Lambda function example demonstrating basic concepts.

## Overview

This function demonstrates:
- Basic Lambda function structure
- Event and context handling
- Logging
- Error handling
- Environment variables
- Response formatting

## Function Code

The function (`lambda_function.py`) includes:
- Proper logging setup
- Error handling
- Environment variable access
- Context information usage

## Testing Locally

### Using Python

```bash
# Install dependencies (if any)
pip install -r requirements.txt

# Test the function
python -c "
import json
from lambda_function import lambda_handler

class Context:
    function_name = 'hello-world'
    aws_request_id = 'test-request-id'
    def get_remaining_time_in_millis(self):
        return 30000

event = {
    'name': 'Developer',
    'message': 'Hello'
}

result = lambda_handler(event, Context())
print(json.dumps(result, indent=2))
"
```

### Using AWS CLI

```bash
# Invoke the function
aws lambda invoke \
  --function-name hello-world \
  --payload '{"name": "Developer", "message": "Hello"}' \
  response.json

# View response
cat response.json
```

## Deployment

This function is deployed via Terraform. See the main `main.tf` file for configuration.

## Environment Variables

Set via Terraform:
- `ENVIRONMENT`: Environment name (dev, staging, prod)

## Monitoring

View logs in CloudWatch:
```bash
aws logs tail /aws/lambda/hello-world --follow
```

