# Cost Management Guide

Strategies for managing and optimizing costs in DevOps Studio labs.

## Understanding Costs

> **💰 Important Cost Note**: The costs below are **monthly estimates** if you keep infrastructure running continuously. **Actual costs to complete a lab and delete it are significantly less** - typically 5-10% of monthly costs depending on how long you keep resources running. For example, completing Lab 01 in 2-4 hours and then destroying it would cost approximately **$2-5** instead of $50-80/month.

### Estimated Monthly Costs vs Completion Costs

*Monthly costs assume resources run continuously for a full month. Completion costs assume you run the lab for the typical completion time and then destroy all resources.*

| Lab | Resources | Monthly Est. Cost (USD) | Expected Cost to Complete* | Typical Time | Free Tier Eligible |
|-----|-----------|------------------------|---------------------------|--------------|-------------------|
| **Lab 01** | VPC, ASG, RDS, ALB | $50-80 | $2-5 | 2-4 hours | Partially |
| **Lab 02** | + EKS cluster | $120-180 | $5-10 | 3-5 hours | No |
| **Lab 03** | + CI/CD resources | $20-40 | $1-2 | 1-2 hours | Partially |
| **Lab 04** | + Monitoring stack | $40-60 | $5-8 | 4-6 hours | No |
| **Lab 05** | + Security tools | $30-50 | $2-3 | 2-3 hours | Partially |
| **Lab 06** | + GitOps tools | $20-30 | $1-2 | 1-2 hours | No |
| **Lab 07** | + Serverless | $25-45 | $1-2 | 1-2 hours | Partially |
| **Lab 08** | + Platform tools | $80-120 | $3-5 | 3-4 hours | No |
| **All Labs** | Complete platform | $200-300 | $20-40 | 15-25 hours | No |

\* *Expected cost to complete assumes you run the lab for the typical completion time (shown in "Typical Time" column) and then destroy all resources. Actual costs may vary based on your completion time, AWS pricing, and region.*

*Costs are estimates for us-west-2 region. Actual costs may vary.*

### Cost Breakdown Example (Lab 01)

**Monthly Cost** (if running continuously for 30 days): ~$50-80

| Resource | Configuration | Monthly Cost | Hourly Cost* |
|----------|---------------|--------------|--------------|
| EC2 Instances | 2x t3.micro | $16.00 | $0.022 |
| Application Load Balancer | Standard ALB | $22.00 | $0.030 |
| RDS MySQL | db.t3.micro, Multi-AZ | $25.00 | $0.034 |
| NAT Gateways | 2x Standard | $45.00 | $0.062 |
| Data Transfer | Typical usage | $5.00 | Variable |
| CloudWatch | Logs and metrics | $3.00 | $0.004 |
| S3 Storage | Terraform state | $1.00 | Negligible |
| **Total** | | **~$117/month** | **~$0.15/hour** |

\* *Hourly costs are approximate and based on pro-rated monthly costs. Some services charge per-hour, others per-GB or per-request.*

**Cost to Complete** (run for 3 hours then destroy): ~$2-4

| Component | 3-Hour Cost | Notes |
|-----------|-------------|-------|
| EC2 Instances | $0.07 | 2 instances × 3 hours × $0.0116/hour |
| Application Load Balancer | $0.09 | ALB charges per hour + LCU |
| RDS Database | $0.10 | Multi-AZ charges per hour |
| NAT Gateways | $0.37 | 2 NAT Gateways × 3 hours × $0.062/hour |
| Data Transfer | $0.10 | Minimal during lab completion |
| CloudWatch | $0.01 | Minimal logs during short run |
| **Total** | **~$0.74** | Plus any data transfer charges |

**💡 Key Insight**: Completing Lab 01 in 3 hours costs approximately **$0.74-2.00** (depending on data transfer), which is about **1-4% of the monthly cost**. The biggest savings come from destroying resources immediately after completion!

---

## Cost Optimization Strategies

### For Learning/Development (Minimize Costs)

**🎯 Best Practice**: Complete labs in focused sessions and destroy resources immediately after. This is the single biggest cost saver!

#### 1. Destroy Immediately After Completion

```bash
# Complete the lab (typically 1-4 hours)
make apply
# ... work through the lab exercises ...

# Destroy resources immediately when done
make destroy  # Per lab
# or
./tools/cleanup.sh  # All labs
```

**Savings**: This is the biggest cost saver! Completing and destroying a lab costs 5-10% of keeping it running for a month.

**Example**: 
- Lab 01 running for 1 month: ~$50-80
- Lab 01 completed in 3 hours and destroyed: ~$2-5
- **Savings: 95-96%**

#### 2. Use Development Environment

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
# Destroy infrastructure immediately after completing lab
make destroy

# Or emergency cleanup for all labs
./tools/cleanup.sh
```

**💡 Pro Tip**: Set a reminder or use a timer to ensure you destroy resources after completing each lab. Even leaving resources running overnight can add significant costs!

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

### Example 3: Cost-Optimized Learning (Recommended)

**Configuration**:
```hcl
instance_type = "t3.micro"
min_size = 1
max_size = 2
desired_capacity = 1
single_nat_gateway = true
multi_az = false
db_instance_class = "db.t3.micro"
```

**Monthly Cost**: ~$30-40 (if kept running)

**Cost to Complete** (3 hours): ~$1-2

**Usage**: 
1. Deploy lab
2. Complete exercises (2-4 hours)
3. **Destroy immediately** when done
4. Repeat for next lab

**Total Cost for All 8 Labs**: ~$20-40 (if completed and destroyed immediately)

**vs Keeping All Labs Running**: ~$200-300/month

---

## Best Practices

1. **🎯 Destroy Immediately**: Complete labs in focused sessions and destroy resources right after - this is the #1 cost saver
2. **Start Small**: Begin with minimal resources, scale up as needed
3. **Monitor Regularly**: Check costs daily during active learning, weekly otherwise
4. **Use Tags**: Tag all resources for cost allocation
5. **Set Alerts**: Configure budget alerts at 50%, 80%, 100%
6. **Time Your Learning**: Complete labs during focused sessions rather than leaving resources running
7. **Use Free Tier**: Maximize free tier usage for learning (first 12 months)
8. **Right-Size**: Match resources to actual usage
9. **Batch Learning**: Complete multiple labs in sequence, then destroy all at once
10. **Set Reminders**: Use timers or reminders to ensure cleanup after lab completion

---

## Cost Resources

- **AWS Pricing Calculator**: https://calculator.aws/
- **AWS Cost Explorer**: AWS Console → Cost Management
- **infracost**: https://www.infracost.io/
- **AWS Well-Architected Cost Optimization**: https://aws.amazon.com/architecture/well-architected/

---

---

## Cost Summary

### Key Takeaways

- **Monthly costs** shown are for continuous operation (30 days)
- **Completion costs** are 5-10% of monthly costs when you destroy resources immediately
- **Biggest savings**: Destroy resources immediately after completing each lab
- **All 8 labs completed**: ~$20-40 total (vs $200-300/month if kept running)
- **Best practice**: Complete labs in focused 2-4 hour sessions, then destroy

### Cost Comparison

| Scenario | Lab 01 Cost | All 8 Labs Cost |
|----------|-------------|-----------------|
| **Run for 1 month** | $50-80 | $200-300 |
| **Complete & destroy** | $2-5 | $20-40 |
| **Savings** | **95-96%** | **90-95%** |

**Remember**: Costs are estimates. Monitor your actual usage and adjust accordingly. The most important cost optimization is destroying resources immediately after completing labs!

