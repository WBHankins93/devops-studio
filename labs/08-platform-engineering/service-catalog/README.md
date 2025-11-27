# Service Catalog

The service catalog contains pre-configured infrastructure templates that represent "Golden Paths" - best-practice, approved infrastructure configurations.

## Overview

### What is a Service Catalog?

A service catalog is a collection of infrastructure templates that developers can use to provision standardized, compliant infrastructure. Each template:

- **Follows Best Practices**: Pre-configured with security, scalability, and reliability in mind
- **Is Governed**: Approved by platform team, includes guardrails
- **Is Documented**: Clear documentation on usage and parameters
- **Is Versioned**: Template versions for stability and updates

### Benefits

1. **Consistency**: All services follow the same patterns
2. **Speed**: Faster provisioning with pre-built templates
3. **Compliance**: Built-in security and compliance
4. **Cost Control**: Optimized resource configurations

## Available Templates

### 1. Web Application

**Purpose**: Standard web application with load balancing and database

**Components**:
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- RDS Database (MySQL/PostgreSQL)
- Security Groups
- CloudWatch Monitoring

**Use Cases**:
- Traditional web applications
- REST APIs with database
- Multi-tier applications

**Parameters**:
- Application name
- Environment (dev/staging/prod)
- Instance type
- Database size
- Replica count

See [web-app/README.md](web-app/README.md) for details.

### 2. API Service

**Purpose**: Serverless API with API Gateway and Lambda

**Components**:
- API Gateway (REST API)
- Lambda Functions
- DynamoDB Table
- CloudWatch Logs
- X-Ray Tracing

**Use Cases**:
- RESTful APIs
- Microservices
- Serverless backends

**Parameters**:
- API name
- Environment
- Lambda runtime
- DynamoDB capacity
- CORS settings

See [api-service/README.md](api-service/README.md) for details.

### 3. Data Pipeline

**Purpose**: ETL pipeline for data processing

**Components**:
- AWS Glue Jobs
- S3 Buckets (raw, processed)
- IAM Roles
- EventBridge Rules
- CloudWatch Monitoring

**Use Cases**:
- Data transformation
- ETL workflows
- Batch processing

**Parameters**:
- Pipeline name
- Source S3 bucket
- Destination S3 bucket
- Processing schedule
- Glue job configuration

See [data-pipeline/README.md](data-pipeline/README.md) for details.

## Using Templates

### Via Portal

1. Navigate to Service Catalog in portal
2. Browse available templates
3. Select a template
4. Configure parameters
5. Review and provision

### Via API

```bash
curl -X POST https://platform-api/provision \
  -H "Content-Type: application/json" \
  -d '{
    "template": "web-app",
    "parameters": {
      "name": "my-app",
      "environment": "dev"
    }
  }'
```

### Via CLI

```bash
platform provision web-app \
  --name my-app \
  --environment dev \
  --instance-type t3.medium
```

## Template Structure

Each template includes:

```
template-name/
├── README.md              # Template documentation
├── main.tf                # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf             # Output values
├── terraform.tfvars.example # Example configuration
└── schema.json            # Parameter schema for validation
```

## Creating Custom Templates

### Template Requirements

1. **Terraform Code**: Well-structured, documented Terraform
2. **Parameter Schema**: JSON schema for validation
3. **Documentation**: Clear README with examples
4. **Testing**: Tested in dev environment
5. **Approval**: Reviewed by platform team

### Template Guidelines

- Use consistent naming conventions
- Include all necessary resources
- Add monitoring and logging
- Follow security best practices
- Document all parameters
- Include cost estimates

## Versioning

Templates are versioned using semantic versioning:

- **Major**: Breaking changes
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes

## Best Practices

1. **Start Simple**: Begin with basic templates
2. **Iterate**: Improve based on feedback
3. **Document**: Comprehensive documentation
4. **Test**: Test in dev before production
5. **Monitor**: Track template usage and issues

