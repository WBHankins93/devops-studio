# Cost Management Guide

Strategies for managing and optimizing costs in DevOps Studio labs.

## Understanding Costs

### Estimated Monthly Costs

| Lab | Resources | Estimated Cost (USD) | Free Tier Eligible |
|-----|-----------|---------------------|-------------------|
| **Lab 01** | VPC, ASG, RDS, ALB | $50-80 | Partially |
| **Lab 02** | + EKS cluster | $120-180 | No |
| **Lab 03** | + CI/CD resources | $20-40 | Partially |
| **Lab 04** | + Monitoring stack | $40-60 | No |
| **Lab 05** | + Security tools | $30-50 | Partially |
| **Lab 06** | + GitOps tools | $20-30 | No |
| **Lab 07** | + Serverless | $25-45 | Partially |
| **Lab 08** | + Platform tools | $80-120 | No |
| **All Labs** | Complete platform | $200-300 | No |

*Costs are estimates for us-west-2 region. Actual costs may vary.*

### Cost Breakdown (Lab 01 Example)

| Resource | Configuration | Monthly Cost |
|----------|---------------|--------------|
| EC2 Instances | 2x t3.micro | $16.00 |
| Application Load Balancer | Standard ALB | $22.00 |
| RDS MySQL | db.t3.micro, Multi-AZ | $25.00 |
| NAT Gateways | 2x Standard | $45.00 |
| Data Transfer | Typical usage | $5.00 |
| CloudWatch | Logs and metrics | $3.00 |
| S3 Storage | Terraform state | $1.00 |
| **Total** | | **~$117/month** |

---

## Cost Optimization Strategies

### For Learning/Development

#### 1. Use Development Environment

```bash
# Deploy with dev configuration (smaller resources)
make apply ENV=dev
```

**Dev Environment Savings**:
- Smaller instance types (t3.micro vs t3.medium)
- Fewer instances (1-2 vs 3+)
- Single NAT Gateway option
- Minimal storage

#### 2. Scale Down When Not in Use

```bash
# Scale to zero instances
terraform apply -var="desired_capacity=0" -var="min_size=0"

# Scale back up when needed
terraform apply -var="desired_capacity=2" -var="min_size=1"
```

**Savings**: ~$16/month per instance stopped

#### 3. Use Single NAT Gateway

```hcl
# In terraform.tfvars or dev.tfvars
single_nat_gateway = true
```

**Savings**: ~$22.50/month (one NAT Gateway instead of two)

#### 4. Disable Deletion Protection

```hcl
# For development only!
enable_deletion_protection = false
```

Allows easier cleanup and prevents accidental costs.

#### 5. Use Spot Instances (Advanced)

```hcl
# Modify launch template to use spot instances
# Can save 50-90% on compute costs
# Note: Instances can be terminated with 2-minute notice
```

#### 6. Reduce RDS Costs

```hcl
# Use single-AZ (dev only)
multi_az = false

# Smaller instance
db_instance_class = "db.t3.micro"

# Minimal storage
db_allocated_storage = 20
```

**Savings**: ~$12.50/month (single-AZ vs Multi-AZ)

#### 7. Clean Up Regularly

```bash
# Destroy infrastructure when done
make destroy

# Or emergency cleanup
./tools/cleanup.sh
```

---

### For Production Reference

#### 1. Right-Sizing

- **Monitor Usage**: Use CloudWatch metrics
- **Analyze Performance**: Identify over-provisioned resources
- **Adjust Gradually**: Start conservative, scale up as needed

#### 2. Reserved Instances

For predictable workloads:
- **Standard RIs**: Up to 72% savings (1-3 year term)
- **Convertible RIs**: Up to 54% savings (flexible)
- **Savings Plans**: Up to 72% savings (flexible compute)

#### 3. Auto Scaling

```hcl
# Configure proper scaling policies
min_size = 2
max_size = 10
desired_capacity = 3

# Scale based on metrics
scale_up_threshold = 70
scale_down_threshold = 30
```

#### 4. Cost Allocation Tags

All resources are automatically tagged:
- `Project`: DevOps Studio
- `Environment`: dev/staging/prod
- `ManagedBy`: Terraform
- `CostCenter`: Engineering

Use tags for cost allocation and tracking.

#### 5. S3 Lifecycle Policies

```hcl
# Automatically move old logs to cheaper storage
# Or delete after retention period
```

#### 6. CloudWatch Log Retention

```hcl
# Reduce log retention for non-production
log_retention_days = 7  # Instead of 30
```

**Savings**: ~$1-2/month per log group

---

## Cost Monitoring

### AWS Cost Explorer

1. **Access**: AWS Console → Cost Management → Cost Explorer
2. **View Costs**: Daily, monthly, by service
3. **Filter by Tags**: Use `Project=DevOps Studio` tag
4. **Forecast**: Predict future costs

### Cost Estimation Tools

#### Using infracost

```bash
# Install infracost
brew install infracost  # macOS
# or see: https://www.infracost.io/docs/

# Estimate costs
cd labs/01-terraform-foundations
infracost breakdown --path . --terraform-var-file environments/dev.tfvars
```

#### Using Cost Estimation Script

```bash
# Run cost estimation
./tools/cost-estimate.sh
```

### AWS Budgets

Set up budget alerts:

```bash
# Create budget (one-time setup)
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://budget-config.json
```

**Budget Configuration** (`budget-config.json`):
```json
{
  "BudgetName": "DevOps-Studio-Monthly",
  "BudgetLimit": {
    "Amount": "100",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostFilters": {
    "TagKeyValue": [
      "user:Project$DevOps Studio"
    ]
  }
}
```

---

## AWS Free Tier

### Eligible Services (First 12 Months)

- **EC2**: 750 hours/month of t2.micro or t3.micro
- **RDS**: 750 hours/month of db.t2.micro or db.t3.micro
- **S3**: 5GB storage, 20,000 GET requests
- **Lambda**: 1M free requests, 400,000 GB-seconds
- **CloudWatch**: 10 custom metrics, 5GB log ingestion

### Free Tier Optimization

```hcl
# Use free tier eligible resources
instance_type = "t3.micro"        # Free tier eligible
db_instance_class = "db.t3.micro" # Free tier eligible
```

**Note**: Load balancers and NAT Gateways are NOT free tier eligible.

---

## Cost Optimization Checklist

### Before Deployment

- [ ] Choose appropriate instance sizes
- [ ] Use dev environment for learning
- [ ] Set up cost alerts
- [ ] Review cost estimates
- [ ] Enable cost allocation tags

### During Deployment

- [ ] Monitor costs daily (first week)
- [ ] Review CloudWatch metrics
- [ ] Adjust resources based on usage
- [ ] Clean up unused resources

### After Deployment

- [ ] Review monthly costs
- [ ] Identify optimization opportunities
- [ ] Right-size resources
- [ ] Set up automated cleanup (if applicable)

---

## Emergency Cost Control

### Immediate Actions

```bash
# 1. Stop all instances
terraform apply -var="desired_capacity=0" -var="min_size=0"

# 2. Emergency cleanup
./tools/cleanup.sh

# 3. Check for orphaned resources
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`]'
aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus==`available`]'
```

### Cost Anomaly Detection

Set up CloudWatch anomaly detection:

```bash
# Monitor for unusual cost spikes
aws cloudwatch put-metric-alarm \
  --alarm-name "HighCostAlert" \
  --alarm-description "Alert when costs exceed threshold" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --evaluation-periods 1 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold
```

---

## Cost Optimization Examples

### Example 1: Development Environment

**Configuration**:
```hcl
instance_type = "t3.micro"
min_size = 1
max_size = 2
desired_capacity = 1
single_nat_gateway = true
multi_az = false
```

**Monthly Cost**: ~$60-70 (vs ~$117 for default)

**Savings**: ~$50/month

### Example 2: Production Environment

**Configuration**:
```hcl
instance_type = "t3.medium"
min_size = 3
max_size = 10
desired_capacity = 3
single_nat_gateway = false  # HA required
multi_az = true
```

**Monthly Cost**: ~$200-250

**Includes**: High availability, auto-scaling, monitoring

### Example 3: Cost-Optimized Learning

**Configuration**:
```hcl
instance_type = "t3.micro"
min_size = 0
max_size = 2
desired_capacity = 0  # Scale up only when needed
single_nat_gateway = true
multi_az = false
db_instance_class = "db.t3.micro"
```

**Monthly Cost**: ~$30-40 (when scaled to 0)

**Usage**: Scale up only when actively learning

---

## Best Practices

1. **Start Small**: Begin with minimal resources, scale up as needed
2. **Monitor Regularly**: Check costs weekly, especially first month
3. **Use Tags**: Tag all resources for cost allocation
4. **Set Alerts**: Configure budget alerts at 50%, 80%, 100%
5. **Clean Up**: Destroy resources when not in use
6. **Review Monthly**: Analyze costs and optimize
7. **Use Free Tier**: Maximize free tier usage for learning
8. **Right-Size**: Match resources to actual usage

---

## Cost Resources

- **AWS Pricing Calculator**: https://calculator.aws/
- **AWS Cost Explorer**: AWS Console → Cost Management
- **infracost**: https://www.infracost.io/
- **AWS Well-Architected Cost Optimization**: https://aws.amazon.com/architecture/well-architected/

---

**Remember**: Costs are estimates. Monitor your actual usage and adjust accordingly!

