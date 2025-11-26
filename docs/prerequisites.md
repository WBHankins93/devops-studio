# Prerequisites Guide

This guide details all requirements for using DevOps Studio labs.

## Required Tools

### AWS CLI (v2.0+)

**Purpose**: Interact with AWS services

**Installation**:
```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
```

**Configuration**:
```bash
aws configure
# Enter: Access Key, Secret Key, Region, Output Format
```

**Documentation**: [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/)

---

### Terraform (v1.5+)

**Purpose**: Infrastructure as Code

**Installation**:
```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify
terraform version
```

**Documentation**: [Terraform Documentation](https://www.terraform.io/docs)

---

### Git (v2.0+)

**Purpose**: Version control

**Installation**:
```bash
# macOS
brew install git

# Linux
sudo apt-get install git  # Debian/Ubuntu
sudo yum install git      # RHEL/CentOS

# Verify
git --version
```

**Documentation**: [Git Documentation](https://git-scm.com/doc)

---

### curl

**Purpose**: HTTP requests for testing

**Installation**:
- Usually pre-installed on macOS and Linux
- If missing: `brew install curl` (macOS) or `sudo apt-get install curl` (Linux)

---

## Optional but Recommended Tools

### kubectl (v1.28+)

**Purpose**: Kubernetes cluster management (Lab 02+)

**Installation**:
```bash
# macOS
brew install kubernetes-cli

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify
kubectl version --client
```

**Documentation**: [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)

---

### Helm (v3.10+)

**Purpose**: Kubernetes package management (Lab 02+)

**Installation**:
```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

**Documentation**: [Helm Documentation](https://helm.sh/docs/)

---

### Docker (v20.0+)

**Purpose**: Container management (Lab 03+)

**Installation**:
```bash
# macOS
brew install --cask docker

# Linux
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Verify
docker --version
```

**Documentation**: [Docker Documentation](https://docs.docker.com/)

---

### jq

**Purpose**: JSON processing (helpful for scripts)

**Installation**:
```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq  # Debian/Ubuntu
sudo yum install jq      # RHEL/CentOS

# Verify
jq --version
```

---

### infracost

**Purpose**: Cost estimation for Terraform

**Installation**:
```bash
# macOS
brew install infracost

# Linux
bash -c "$(curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh)"

# Verify
infracost --version
```

**Documentation**: [infracost Documentation](https://www.infracost.io/docs/)

---

### tfsec

**Purpose**: Security scanning for Terraform

**Installation**:
```bash
# macOS
brew install tfsec

# Linux
brew install tfsec  # Using Homebrew on Linux
# Or download from: https://github.com/aquasecurity/tfsec/releases

# Verify
tfsec --version
```

**Documentation**: [tfsec Documentation](https://github.com/aquasecurity/tfsec)

---

## AWS Account Requirements

### Account Setup

1. **AWS Account** with billing enabled
   - Sign up at [aws.amazon.com](https://aws.amazon.com)
   - Enable billing (required for most services)
   - Set up payment method

2. **IAM User** with programmatic access
   - Create dedicated IAM user (don't use root account)
   - Enable programmatic access (Access Key + Secret Key)
   - Attach required policies (see below)

### Required IAM Permissions

For learning purposes, you can use `PowerUserAccess` policy. For production, use least-privilege policies.

**Minimum Required Permissions**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "vpc:*",
        "rds:*",
        "eks:*",
        "iam:CreateRole",
        "iam:CreatePolicy",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:GetRole",
        "iam:GetPolicy",
        "iam:ListRoles",
        "iam:ListPolicies",
        "iam:PassRole",
        "cloudwatch:*",
        "logs:*",
        "s3:*",
        "dynamodb:*",
        "lambda:*",
        "apigateway:*",
        "secretsmanager:*",
        "ssm:*",
        "kms:*",
        "autoscaling:*",
        "elasticloadbalancing:*",
        "application-autoscaling:*",
        "servicequotas:GetServiceQuota",
        "servicequotas:ListServiceQuotas"
      ],
      "Resource": "*"
    }
  ]
}
```

**Recommended**: Use `PowerUserAccess` for learning (excludes IAM management).

### Service Quotas

Some AWS services have default quotas. You may need to request increases:

- **EC2**: Running On-Demand instances (default: 20)
- **VPC**: VPCs per region (default: 5)
- **RDS**: DB instances (default: 40)
- **EKS**: Clusters per region (default: 4)

**Check Quotas**:
```bash
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-34B43A08
```

**Request Increase**: AWS Console → Service Quotas → Request quota increase

---

## System Requirements

### Operating System

- **macOS**: 10.15+ (Catalina or later)
- **Linux**: Ubuntu 20.04+, RHEL 8+, or similar
- **Windows**: Windows 10/11 with WSL2 (Ubuntu recommended)

### Hardware

- **CPU**: 2+ cores recommended
- **Memory**: 4GB minimum, 8GB+ recommended
- **Disk Space**: 5GB+ free space
- **Network**: Reliable internet connection (for AWS API calls)

### Network

- **Internet**: Required for AWS API access
- **Bandwidth**: Minimal (mostly API calls, not data transfer)
- **Firewall**: Allow outbound HTTPS (443) to AWS endpoints

---

## Knowledge Prerequisites

### Essential (Before Starting)

- **Command Line**: Basic familiarity with terminal/command prompt
- **Git Basics**: Clone, commit, push
- **Cloud Concepts**: Understanding of cloud computing basics
- **Text Editor**: Comfortable editing configuration files

### Helpful (Will Learn as You Go)

- **AWS Basics**: EC2, VPC, S3 concepts
- **Terraform Basics**: Resources, modules, state
- **Networking**: Subnets, routing, security groups
- **Containers**: Docker basics (for Lab 02+)
- **Kubernetes**: Basic concepts (for Lab 02+)

### Learning Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Learn](https://learn.hashicorp.com/terraform)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Docker Getting Started](https://docs.docker.com/get-started/)

---

## Verification

### Quick Check

Run the validation script:

```bash
./tools/validate.sh
```

This checks:
- ✅ All required tools installed
- ✅ Tool versions meet requirements
- ✅ AWS CLI configured
- ✅ System resources adequate
- ⚠️ Optional tools (warnings only)

### Manual Verification

```bash
# Check AWS
aws --version
aws sts get-caller-identity

# Check Terraform
terraform version

# Check Git
git --version

# Check optional tools
kubectl version --client 2>/dev/null || echo "kubectl not installed"
helm version 2>/dev/null || echo "helm not installed"
docker --version 2>/dev/null || echo "docker not installed"
```

---

## Troubleshooting Installation

### AWS CLI Issues

**Problem**: `aws: command not found`
```bash
# Check installation
which aws
# If not found, reinstall or add to PATH
```

**Problem**: `Unable to locate credentials`
```bash
# Configure credentials
aws configure
# Or set environment variables
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

### Terraform Issues

**Problem**: `terraform: command not found`
```bash
# Check installation
which terraform
# If not found, reinstall or add to PATH
```

**Problem**: Version too old
```bash
# Update Terraform
# macOS
brew upgrade terraform

# Linux
# Download latest from: https://terraform.io/downloads
```

### Permission Issues

**Problem**: `Permission denied` when running scripts
```bash
# Make scripts executable
chmod +x tools/*.sh
chmod +x labs/*/scripts/*.sh
```

---

## Next Steps

Once all prerequisites are met:

1. **Run Bootstrap**
   ```bash
   ./tools/bootstrap.sh
   ```

2. **Run Setup**
   ```bash
   ./tools/setup.sh
   ```

3. **Start Your First Lab**
   ```bash
   cd labs/01-terraform-foundations
   make apply
   ```

---

## Additional Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform Downloads](https://www.terraform.io/downloads)
- [Kubernetes Installation](https://kubernetes.io/docs/tasks/tools/)
- [Docker Installation](https://docs.docker.com/get-docker/)

---

**Ready?** Proceed to [Getting Started Guide](./getting-started.md)!

