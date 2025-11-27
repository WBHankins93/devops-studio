# API Service Template

A serverless API template with API Gateway, Lambda, and DynamoDB.

## Overview

This template provisions a complete serverless API stack:

- **API Gateway** - REST API endpoint
- **Lambda Functions** - Serverless compute
- **DynamoDB** - NoSQL database
- **CloudWatch** - Logging and monitoring
- **X-Ray** - Distributed tracing

## Architecture

```
Internet
    │
    ▼
┌──────────────┐
│ API Gateway  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Lambda     │
│  Functions   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   DynamoDB   │
└──────────────┘
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `api_name` | string | Yes | - | API name |
| `environment` | string | Yes | - | Environment (dev/staging/prod) |
| `lambda_runtime` | string | No | python3.11 | Lambda runtime |
| `lambda_memory` | number | No | 256 | Lambda memory (MB) |
| `dynamodb_billing_mode` | string | No | PAY_PER_REQUEST | DynamoDB billing mode |

## Usage

### Via Portal

1. Select "API Service" from catalog
2. Fill in parameters
3. Review configuration
4. Click "Provision"

## Cost Estimate

**Monthly Cost** (dev environment, low usage):
- API Gateway: ~$3.50 per million requests
- Lambda: ~$0.20 per million requests + compute
- DynamoDB: Pay-per-request pricing
- **Total: ~$5-15/month** (depending on usage)

## Security Features

- API Gateway authentication
- IAM roles for Lambda
- DynamoDB encryption at rest
- VPC endpoints (optional)
- CloudWatch logging

