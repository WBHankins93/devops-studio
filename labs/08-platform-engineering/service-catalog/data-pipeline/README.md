# Data Pipeline Template

A template for ETL data processing pipelines using AWS Glue.

## Overview

This template provisions:
- **AWS Glue Jobs** - ETL processing
- **S3 Buckets** - Raw and processed data storage
- **IAM Roles** - Glue execution roles
- **EventBridge Rules** - Scheduled execution
- **CloudWatch** - Monitoring and logging

## Architecture

```
S3 (Raw Data)
    │
    ▼
┌──────────────┐
│  Glue Job    │ (ETL Processing)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ S3 (Processed)│
└──────────────┘
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `pipeline_name` | string | Yes | - | Pipeline name |
| `environment` | string | Yes | - | Environment (dev/staging/prod) |
| `source_bucket` | string | Yes | - | Source S3 bucket |
| `destination_bucket` | string | Yes | - | Destination S3 bucket |
| `schedule` | string | No | daily | Execution schedule |

## Usage

### Via Portal

1. Select "Data Pipeline" from catalog
2. Fill in parameters
3. Review configuration
4. Click "Provision"

## Cost Estimate

**Monthly Cost** (dev environment):
- Glue: ~$0.44 per DPU-hour
- S3: Pay-per-storage
- **Total: ~$10-30/month** (depending on data volume)

## Implementation

Terraform template would be similar to web-app template, provisioning:
- Glue job definitions
- S3 buckets with lifecycle policies
- IAM roles for Glue
- EventBridge rules for scheduling

