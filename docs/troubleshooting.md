# Troubleshooting Guide

Common issues and solutions for DevOps Studio labs.

## Quick Diagnostics

### Check System Status

```bash
# Validate system
./tools/validate.sh

# Check AWS connection
aws sts get-caller-identity

# Check Terraform
terraform version
terraform validate
```

### Enable Debug Logging

```bash
# Terraform debug
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform plan

# AWS CLI debug
export AWS_CLI_LOG_LEVEL=debug
aws <command>
```

---

## Common Issues

### AWS Configuration

#### Issue: Unable to locate credentials

**Symptoms**:
```
Error: Unable to locate credentials
```

**Solutions**:
```bash
# 1. Configure AWS CLI
aws configure

# 2. Check credentials file
cat ~/.aws/credentials

# 3. Set environment variables
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_DEFAULT_REGION=us-west-2

# 4. Verify
aws sts get-caller-identity
```

#### Issue: User is not authorized

**Symptoms**:
```
Error: User: arn:aws:iam::xxx:user/xxx is not authorized to perform: xxx
```

**Solutions**:
1. Check IAM user has required permissions
2. Attach `PowerUserAccess` policy (for learning)
3. Or create custom policy with required permissions
4. See [Prerequisites Guide](./prerequisites.md) for required permissions

#### Issue: Service quota exceeded

**Symptoms**:
```
Error: You have requested more than the maximum allowed number of instances
```

**Solutions**:
```bash
# Check current quota
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-34B43A08

# Request increase
# AWS Console → Service Quotas → Request quota increase
```

---

### Terraform Issues

#### Issue: Backend setup fails

**Symptoms**:
```
Error: InvalidUserID.NotFound
Error: BucketAlreadyExists
```

**Solutions**:
```bash
# 1. Check AWS CLI configuration
aws sts get-caller-identity

# 2. S3 bucket names are globally unique
# Edit PROJECT_NAME in setup-backend.sh
# Or use existing bucket

# 3. Check bucket doesn't exist
aws s3 ls | grep terraform-state

# 4. Manually create backend
./scripts/setup-backend.sh
```

#### Issue: State lock error

**Symptoms**:
```
Error: Error acquiring the state lock
```

**Solutions**:
```bash
# 1. Check for stuck locks
aws dynamodb scan \
  --table-name devops-studio-terraform-locks

# 2. Force unlock (use carefully!)
terraform force-unlock <lock-id>

# 3. Check if another process is running
ps aux | grep terraform
```

#### Issue: Resources show constant changes

**Symptoms**:
```
Terraform plan shows changes on every run
```

**Solutions**:
```bash
# 1. Refresh state
terraform refresh

# 2. Check for configuration drift
terraform plan -detailed-exitcode

# 3. Review resource tags (may cause drift)
# Ensure tags are consistent

# 4. Check for computed values
terraform show
```

#### Issue: Provider version conflicts

**Symptoms**:
```
Error: Failed to query available provider packages
```

**Solutions**:
```bash
# 1. Update provider versions in main.tf
# 2. Remove lock file and reinitialize
rm .terraform.lock.hcl
terraform init -upgrade

# 3. Check Terraform version
terraform version
# Update if needed
```

---

### Infrastructure Issues

#### Issue: Application returns 502 errors

**Symptoms**:
```
Load balancer returns Bad Gateway (502)
```

**Solutions**:
```bash
# 1. Check instance health
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "devops-studio-dev-asg"

# 2. Check target group health
ALB_ARN=$(terraform output -raw load_balancer_arn)
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
    --load-balancer-arn $ALB_ARN \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

# 3. Check application logs
make logs
# or
aws logs tail /aws/ec2/devops-studio-dev --follow

# 4. Check security groups
# Ensure ALB can reach instances on port 80
```

#### Issue: Database connection issues

**Symptoms**:
```
Cannot connect to RDS database
```

**Solutions**:
```bash
# 1. Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier "devops-studio-dev-db"

# 2. Verify security groups
# Database SG should allow port 3306 from app SG
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=*database*"

# 3. Check subnet group
aws rds describe-db-subnet-groups \
  --db-subnet-group-name "devops-studio-dev-db-subnet-group"

# 4. Test connectivity from instance
# SSH to instance and test:
mysql -h <db-endpoint> -u admin -p
```

#### Issue: Auto Scaling not working

**Symptoms**:
```
Instances not scaling up/down
```

**Solutions**:
```bash
# 1. Check CloudWatch alarms
aws cloudwatch describe-alarms \
  --alarm-name-prefix "devops-studio"

# 2. Check Auto Scaling policies
aws autoscaling describe-policies \
  --auto-scaling-group-name "devops-studio-dev-asg"

# 3. Check scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name "devops-studio-dev-asg"

# 4. Verify metrics are being collected
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=devops-studio-dev-asg \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

---

### Network Issues

#### Issue: Cannot SSH to instances

**Symptoms**:
```
Connection timeout when trying to SSH
```

**Solutions**:
```bash
# 1. Check security group rules
# SSH should be allowed from your IP
aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=*web-app*"

# 2. Use SSM Session Manager instead
make ssh
# or
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-studio-dev-web-app" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)
aws ssm start-session --target $INSTANCE_ID

# 3. Check instance is in public subnet (if using SSH key)
# Or ensure NAT Gateway is configured (for private subnets)
```

#### Issue: VPC Flow Logs not appearing

**Symptoms**:
```
No logs in CloudWatch Logs
```

**Solutions**:
```bash
# 1. Check Flow Log status
aws ec2 describe-flow-logs \
  --filter "Name=resource-id,Values=$(terraform output -raw vpc_id)"

# 2. Check IAM role permissions
aws iam get-role-policy \
  --role-name devops-studio-dev-vpc-flow-logs-role \
  --policy-name devops-studio-dev-vpc-flow-logs-policy

# 3. Check CloudWatch Log Group
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/vpc/flowlogs"
```

---

### Cost Issues

#### Issue: Unexpected high costs

**Symptoms**:
```
AWS bill higher than expected
```

**Solutions**:
```bash
# 1. Check running resources
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Project`].Value|[0]]'

# 2. Check RDS instances
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'

# 3. Check NAT Gateways (expensive!)
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available"

# 4. Check load balancers
aws elbv2 describe-load-balancers

# 5. Emergency cleanup
./tools/cleanup.sh

# 6. Set up cost alerts
# AWS Console → Billing → Budgets → Create budget
```

#### Issue: Resources not cleaning up

**Symptoms**:
```
terraform destroy fails or leaves resources
```

**Solutions**:
```bash
# 1. Check for dependencies
terraform destroy -target=module.database
terraform destroy -target=module.web_app
terraform destroy -target=module.vpc

# 2. Manual cleanup
# Delete resources in order:
# - Application resources first
# - Database (may take time)
# - Networking resources last

# 3. Check for deletion protection
# Disable in terraform.tfvars:
# enable_deletion_protection = false

# 4. Force cleanup script
./tools/cleanup.sh
```

---

### Validation Issues

#### Issue: Validation tests fail

**Symptoms**:
```
make test fails
```

**Solutions**:
```bash
# 1. Check application is running
ALB_DNS=$(terraform output -raw load_balancer_dns)
curl http://$ALB_DNS/health

# 2. Check all components
./scripts/validate.sh

# 3. Review test output
# Tests may fail if:
# - Infrastructure still deploying (wait 5-10 minutes)
# - Health checks not passing
# - Security groups misconfigured

# 4. Manual validation
# Test each component individually
```

---

## Lab-Specific Issues

### Lab 01 - Terraform Foundations

**Common Issues**:
- Backend setup fails → Check S3 bucket name uniqueness
- RDS takes too long → Normal, can take 10-15 minutes
- ALB health checks failing → Wait for instances to initialize (5-10 min)

### Lab 02 - Kubernetes Platform

**Common Issues**:
- kubectl connection fails → Check kubeconfig
- Helm charts fail → Check EKS cluster is ready
- Pods not starting → Check node group capacity

### Lab 03 - CI/CD Pipelines

**Common Issues**:
- GitHub Actions fail → Check secrets configured
- Docker build fails → Check Dockerfile
- Deployment fails → Check Kubernetes cluster access

---

## Getting Help

### Self-Service

1. **Check Documentation**
   - Lab-specific README
   - [Getting Started Guide](./getting-started.md)
   - [Prerequisites Guide](./prerequisites.md)

2. **Review Logs**
   ```bash
   # Terraform logs
   cat terraform.log

   # Application logs
   make logs

   # CloudWatch logs
   aws logs tail /aws/ec2/devops-studio-dev --follow
   ```

3. **Validate Configuration**
   ```bash
   terraform validate
   terraform fmt -check
   ```

### Community Support

- **GitHub Issues**: Report bugs or request features
- **GitHub Discussions**: Ask questions, share solutions
- **Documentation**: Check for updates

### Debug Mode

Enable detailed logging:

```bash
# Terraform
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform plan

# AWS CLI
export AWS_CLI_LOG_LEVEL=debug
aws <command>

# Review logs
cat terraform.log
```

---

## Prevention Tips

1. **Always Plan Before Apply**
   ```bash
   terraform plan  # Review changes
   ```

2. **Use Version Control**
   ```bash
   git commit -m "Before changes"
   ```

3. **Test in Dev First**
   ```bash
   make apply ENV=dev  # Test changes
   ```

4. **Monitor Costs**
   ```bash
   ./tools/cost-estimate.sh
   ```

5. **Clean Up Regularly**
   ```bash
   make destroy  # When done with lab
   ```

---

## Emergency Procedures

### Complete Infrastructure Failure

```bash
# 1. Emergency cleanup
./tools/cleanup.sh

# 2. Verify cleanup
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`]'

# 3. Check costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -u -d '1 day ago' +%Y-%m-%d),End=$(date -u +%Y-%m-%d) \
  --granularity DAILY \
  --metrics BlendedCost
```

### Data Loss Prevention

```bash
# 1. Create snapshots before changes
aws rds create-db-snapshot \
  --db-instance-identifier devops-studio-dev-db \
  --db-snapshot-identifier backup-$(date +%Y%m%d)

# 2. Export Terraform state
terraform state pull > state-backup.json

# 3. Tag critical resources
# Ensure deletion_protection = true for production
```

---

**Still stuck?** Create a GitHub issue with:
- Error message
- Steps to reproduce
- Terraform version
- AWS region
- Relevant logs

