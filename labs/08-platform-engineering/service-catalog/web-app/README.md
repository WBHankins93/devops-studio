# Web Application Template

A production-ready template for web applications with load balancing, auto-scaling, and database.

## Overview

This template provisions a complete web application stack:

- **Application Load Balancer (ALB)** - Load balancing and SSL termination
- **Auto Scaling Group (ASG)** - Auto-scaling EC2 instances
- **RDS Database** - Managed database (MySQL or PostgreSQL)
- **Security Groups** - Network security
- **CloudWatch** - Monitoring and logging

## Architecture

```
Internet
    │
    ▼
┌──────────────┐
│      ALB     │ (Application Load Balancer)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│      ASG     │ (Auto Scaling Group)
│  EC2 Instances│
└──────┬───────┘
       │
       ▼
┌──────────────┐
│     RDS      │ (Database)
└──────────────┘
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `app_name` | string | Yes | - | Application name |
| `environment` | string | Yes | - | Environment (dev/staging/prod) |
| `instance_type` | string | No | t3.medium | EC2 instance type |
| `min_size` | number | No | 2 | Minimum instances |
| `max_size` | number | No | 10 | Maximum instances |
| `desired_capacity` | number | No | 2 | Desired instances |
| `db_instance_class` | string | No | db.t3.micro | RDS instance class |
| `db_engine` | string | No | mysql | Database engine (mysql/postgres) |
| `db_allocated_storage` | number | No | 20 | Database storage (GB) |

## Usage

### Via Portal

1. Select "Web Application" from catalog
2. Fill in parameters
3. Review configuration
4. Click "Provision"

### Via Terraform

```hcl
module "web_app" {
  source = "./service-catalog/web-app"
  
  app_name     = "my-web-app"
  environment  = "dev"
  instance_type = "t3.medium"
  min_size     = 2
  max_size     = 10
}
```

## Outputs

- `alb_dns_name` - ALB DNS name for accessing the application
- `rds_endpoint` - RDS database endpoint
- `security_group_id` - Security group ID
- `asg_name` - Auto Scaling Group name

## Cost Estimate

**Monthly Cost** (dev environment):
- ALB: ~$16/month
- EC2 (2x t3.medium): ~$60/month
- RDS (db.t3.micro): ~$15/month
- **Total: ~$91/month**

**Cost to Complete** (run for 3-4 hours): ~$5-10

## Security Features

- SSL/TLS termination at ALB
- Security groups with least privilege
- RDS encryption at rest
- VPC isolation
- CloudWatch logging

## Monitoring

- CloudWatch metrics for ALB, ASG, and RDS
- Auto-scaling based on CPU/memory
- Health checks for instances
- Database monitoring

## Best Practices

1. **Use Multiple AZs**: Deploy across availability zones
2. **Enable Auto-Scaling**: Handle traffic spikes
3. **Monitor Costs**: Set up budget alerts
4. **Regular Backups**: Enable RDS automated backups
5. **Update Regularly**: Keep AMIs and database updated

