# Getting Started Guide

Welcome to DevOps Studio! This guide will help you get up and running quickly.

## Quick Start (5 minutes)

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd devops-studio
```

### Step 2: Bootstrap Your Environment

```bash
./tools/bootstrap.sh
```

This script will:
- Make all scripts executable
- Validate your system requirements
- Configure Git (if needed)

### Step 3: Run Setup

```bash
./tools/setup.sh
```

This interactive script will:
- Validate required tools are installed
- Check AWS configuration
- Help you choose your first lab
- Set up the lab environment

### Step 4: Deploy Your First Lab

```bash
cd labs/01-terraform-foundations
make apply
```

That's it! Your infrastructure is being deployed.

## Detailed Setup

### Prerequisites

Before starting, ensure you have:

1. **AWS Account** with billing enabled
2. **AWS CLI** configured with credentials
3. **Required Tools** installed (see [Prerequisites Guide](./prerequisites.md))

### System Requirements

- **Operating System**: macOS, Linux, or Windows WSL2
- **Memory**: 4GB+ recommended
- **Disk Space**: 5GB+ free
- **Network**: Reliable internet connection

### AWS Configuration

#### 1. Create AWS Account

If you don't have an AWS account:
1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Click "Create an AWS Account"
3. Follow the registration process
4. Enable billing (required for most services)

#### 2. Create IAM User

For security best practices, create a dedicated IAM user:

1. Go to AWS Console → IAM → Users
2. Click "Add users"
3. Create user with programmatic access
4. Attach policies:
   - `PowerUserAccess` (for learning)
   - Or create custom policy with required permissions (see Prerequisites)

#### 3. Configure AWS CLI

```bash
aws configure
```

Enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., `us-west-2`)
- Default output format (e.g., `json`)

Verify configuration:
```bash
aws sts get-caller-identity
```

### Tool Installation

#### macOS

```bash
# Homebrew
brew install terraform awscli kubernetes-cli helm docker

# Or use the install script
./tools/install-tools.sh  # If available
```

#### Linux

```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### Windows (WSL2)

Use the Linux installation steps above within WSL2.

### Verification

Run the validation script:

```bash
./tools/validate.sh
```

This checks:
- ✅ All required tools are installed
- ✅ AWS CLI is configured
- ✅ System resources are adequate
- ⚠️ Optional tools (warnings only)

## Choosing Your First Lab

### For Beginners

**Start with Lab 01 - Terraform Foundations**

This lab teaches:
- Infrastructure as Code basics
- AWS VPC networking
- Auto Scaling Groups
- RDS databases
- CloudWatch monitoring

**Time**: 45-60 minutes  
**Cost**: ~$50-80/month (can be reduced)

### For Experienced Users

Choose based on your interests:

- **Kubernetes**: Lab 02
- **CI/CD**: Lab 03
- **Monitoring**: Lab 04
- **Security**: Lab 05
- **GitOps**: Lab 06
- **Serverless**: Lab 07
- **Platform Engineering**: Lab 08

## Lab Workflow

### Standard Workflow

1. **Navigate to Lab**
   ```bash
   cd labs/01-terraform-foundations
   ```

2. **Read the README**
   ```bash
   cat README.md
   ```

3. **Set Up Backend** (if needed)
   ```bash
   ./scripts/setup-backend.sh
   ```

4. **Configure Variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferences
   ```

5. **Initialize Terraform**
   ```bash
   make init
   # or
   terraform init
   ```

6. **Plan Changes**
   ```bash
   make plan
   # or
   terraform plan
   ```

7. **Apply Changes**
   ```bash
   make apply
   # or
   terraform apply
   ```

8. **Test Infrastructure**
   ```bash
   make test
   # or
   ./scripts/validate.sh
   ```

9. **View Outputs**
   ```bash
   make output
   # or
   terraform output
   ```

10. **Clean Up** (when done)
    ```bash
    make destroy
    # or
    terraform destroy
    ```

### Using Make Commands

Each lab includes a `Makefile` with helpful commands:

```bash
make help          # Show all available commands
make init          # Initialize Terraform
make plan          # Create execution plan
make apply         # Apply changes
make destroy       # Destroy infrastructure
make test          # Run validation tests
make output        # Show outputs
make validate      # Validate Terraform config
make format        # Format Terraform code
make cost          # Estimate costs (if infracost installed)
make security      # Security scan (if tfsec installed)
```

## Environment-Specific Deployments

Labs support multiple environments (dev, staging, prod):

```bash
# Deploy to development
make apply ENV=dev

# Deploy to staging
make apply ENV=staging

# Deploy to production
make apply ENV=prod
```

Each environment has its own configuration in `environments/` directory.

## Cost Management

### Understanding Costs

- **Lab 01**: ~$50-80/month
- **Lab 02**: ~$120-180/month
- **All Labs**: ~$200-300/month

### Cost Optimization

1. **Use Development Environment**
   ```bash
   make apply ENV=dev  # Smaller, cheaper resources
   ```

2. **Scale Down When Not in Use**
   ```bash
   terraform apply -var="desired_capacity=0"
   ```

3. **Use Single NAT Gateway** (dev only)
   ```hcl
   single_nat_gateway = true
   ```

4. **Clean Up Regularly**
   ```bash
   ./tools/cleanup.sh  # Emergency cleanup
   ```

5. **Monitor Costs**
   ```bash
   ./tools/cost-estimate.sh
   ```

See [Cost Management Guide](./cost-management.md) for detailed strategies.

## Troubleshooting

### Common Issues

#### AWS CLI Not Configured
```bash
# Error: Unable to locate credentials
# Solution:
aws configure
aws sts get-caller-identity
```

#### Insufficient Permissions
```bash
# Error: User is not authorized
# Solution: Attach required IAM policies
# See Prerequisites guide for required permissions
```

#### Terraform Version Mismatch
```bash
# Error: Unsupported Terraform version
# Solution: Update Terraform
terraform version
# Install latest from: https://terraform.io/downloads
```

#### Backend Setup Fails
```bash
# Error: BucketAlreadyExists
# Solution: S3 bucket names are globally unique
# Edit PROJECT_NAME in setup-backend.sh or use existing bucket
```

For more troubleshooting help, see [Troubleshooting Guide](./troubleshooting.md).

## Next Steps

1. **Complete Lab 01** - Build your foundation
2. **Explore Other Labs** - Based on your interests
3. **Read Documentation** - Deep dive into concepts
4. **Experiment** - Modify configurations and learn
5. **Share** - Contribute improvements back

## Getting Help

- **Documentation**: Check lab-specific README files
- **Troubleshooting**: See [Troubleshooting Guide](./troubleshooting.md)
- **Issues**: Create a GitHub issue
- **Discussions**: Join GitHub Discussions

## Learning Paths

Choose a learning path based on your career goals:

- **Cloud-Native DevOps**: Labs 01 → 02 → 03 → 04 → 06
- **DevSecOps**: Labs 01 → 03 → 05 → 04 → 06
- **Platform Engineering**: Labs 01 → 02 → 06 → 08 → 04
- **Cloud Architect**: Labs 01 → 07 → 02 → 04 → 08

See [Learning Paths Guide](./learning-paths.md) for detailed paths.

## Best Practices

1. **Always Plan Before Apply**
   ```bash
   terraform plan  # Review changes
   terraform apply # Apply only after review
   ```

2. **Use Version Control**
   ```bash
   git add .
   git commit -m "Deploy Lab 01 infrastructure"
   ```

3. **Tag Resources**
   - All resources are automatically tagged
   - Customize tags in `terraform.tfvars`

4. **Monitor Costs**
   - Set up AWS Budget alerts
   - Review costs regularly
   - Clean up unused resources

5. **Document Changes**
   - Update README if you modify labs
   - Document custom configurations
   - Share learnings with community

## Success Checklist

Before moving to the next lab, ensure you:

- ✅ Infrastructure deployed successfully
- ✅ All validation tests pass
- ✅ Application is accessible
- ✅ Monitoring is working
- ✅ Costs are within budget
- ✅ You understand the architecture
- ✅ You've experimented with changes
- ✅ Resources are cleaned up (if not keeping)

---

**Ready to start?** Run `./tools/setup.sh` and begin your DevOps journey!

