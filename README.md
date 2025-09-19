# DevOps Studio - Production-Grade Learning Platform
*Comprehensive Infrastructure, Automation, and Platform Engineering Labs*

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B68EE?logo=terraform)](https://terraform.io)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5?logo=kubernetes)](https://kubernetes.io)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **A curated collection of hands-on DevOps projects demonstrating real-world infrastructure patterns, automation, and best practices.** Each lab is self-contained, deployable, and mirrors production setups used in enterprise environments.

---

## 📑 Table of Contents

- [What Makes This Different](#what-makes-this-different)
- [Repository Structure](#repository-structure)
- [Lab Overview](#lab-overview)
- [Learning Paths](#learning-paths)
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Quick Start Guide](#quick-start-guide)
- [Platform Features](#platform-features)
- [Cost Considerations](#cost-considerations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Additional Resources](#additional-resources)
- [Support](#support)

---

## What Makes This Different

Unlike typical "hello world" tutorials, every project here:

- ✅ **Actually works** - fully deployable and tested in real AWS environments
- ✅ **Production patterns** - uses real-world architectures and enterprise best practices  
- ✅ **Progressive complexity** - from foundational concepts to advanced platform engineering
- ✅ **Self-contained** - complete with setup, execution, and cleanup instructions
- ✅ **Documentation-driven** - clear explanations of why, not just how
- ✅ **Cost conscious** - designed for learning budgets with cleanup automation
- ✅ **Portfolio ready** - demonstrate skills that employers actually need

---

## Repository Structure

```
devops-studio/
├── README.md                           # This file
├── CONTRIBUTING.md                     # Contribution guidelines
├── LICENSE                             # MIT license
├── .gitignore                          # Git ignore patterns
├── .github/
│   └── workflows/                      # CI/CD for this repository
│       ├── validate-terraform.yml      # Terraform validation
│       ├── test-labs.yml              # Lab testing automation
│       └── security-scan.yml          # Security scanning
├── labs/                               # All hands-on learning labs
│   ├── 01-terraform-foundations/       ✅ Production VPC, ASG, RDS
│   ├── 02-kubernetes-platform/         🚧 EKS, Helm, GitOps ready
│   ├── 03-cicd-pipelines/              🔮 GitHub Actions, automated testing
│   ├── 04-observability-stack/         🔮 Prometheus, Grafana, Jaeger
│   ├── 05-security-automation/         🔮 DevSecOps, scanning, policies
│   ├── 06-gitops-workflows/            🔮 ArgoCD, Flux, declarative deployments
│   ├── 07-serverless-ops/              🔮 Lambda, API Gateway, event-driven
│   └── 08-platform-engineering/        🔮 Crossplane, Backstage, IDP
├── shared/                             # Reusable components
│   ├── terraform-modules/              # Common Terraform modules
│   ├── helm-charts/                    # Custom Helm charts
│   ├── scripts/                        # Shared automation scripts
│   └── configs/                        # Configuration templates
├── docs/                               # Platform documentation
│   ├── getting-started.md              # Quick start guide
│   ├── prerequisites.md                # System requirements
│   ├── troubleshooting.md              # Common issues and solutions
│   └── architecture-decisions/         # Design decision records
└── tools/                              # Global platform tools
    ├── setup.sh                        # Environment bootstrap
    ├── cleanup.sh                      # Emergency cleanup all labs
    └── validate.sh                     # Validate system requirements
```

**Legend**: ✅ Complete | 🚧 In Progress | 🔮 Planned

---

## Lab Overview

### Foundation Labs (Start Here)

| Lab | Focus Area | Technologies | Time | Difficulty | Status |
|-----|------------|-------------|------|------------|--------|
| **[01-terraform-foundations](./labs/01-terraform-foundations/)** | Infrastructure as Code | Terraform, AWS VPC, ASG, RDS | 45 min | Beginner | ✅ Complete |
| **[02-kubernetes-platform](./labs/02-kubernetes-platform/)** | Container Orchestration | EKS, Helm, kubectl, Ingress | 60 min | Intermediate | 🚧 Building |
| **[03-cicd-pipelines](./labs/03-cicd-pipelines/)** | Automation & Delivery | GitHub Actions, Docker, Testing | 30 min | Beginner | 🔮 Planned |

### Advanced Labs (After Foundations)

| Lab | Focus Area | Technologies | Time | Difficulty | Status |
|-----|------------|-------------|------|------------|--------|
| **[04-observability-stack](./labs/04-observability-stack/)** | Monitoring & Alerting | Prometheus, Grafana, Jaeger | 90 min | Advanced | 🔮 Planned |
| **[05-security-automation](./labs/05-security-automation/)** | DevSecOps | Trivy, OPA, Falco, RBAC | 75 min | Advanced | 🔮 Planned |
| **[06-gitops-workflows](./labs/06-gitops-workflows/)** | GitOps & CD | ArgoCD, Flux, Kustomize | 60 min | Intermediate | 🔮 Planned |
| **[07-serverless-ops](./labs/07-serverless-ops/)** | Serverless Operations | Lambda, API Gateway, DynamoDB | 45 min | Intermediate | 🔮 Planned |
| **[08-platform-engineering](./labs/08-platform-engineering/)** | Internal Platforms | Crossplane, Backstage, Tekton | 120 min | Expert | 🔮 Planned |

### What You'll Build

By completing all labs, you'll have hands-on experience with:

- **Infrastructure as Code**: Multi-environment Terraform with remote state
- **Container Platforms**: Production-ready EKS cluster with monitoring
- **CI/CD Automation**: GitHub Actions with security scanning and deployments  
- **Observability**: Full-stack monitoring with metrics, logs, and traces
- **Security Integration**: Automated security scanning and policy enforcement
- **GitOps Workflows**: Declarative deployments with ArgoCD
- **Serverless Operations**: Event-driven architectures with AWS Lambda
- **Platform Engineering**: Internal developer platforms with Crossplane

---

## Learning Paths

Choose your path based on your career goals and current experience level:

### 🚀 **Cloud-Native DevOps Engineer**
*Perfect for those targeting modern cloud-native roles*

**Path**: [Lab 01](./labs/01-terraform-foundations/) → [Lab 02](./labs/02-kubernetes-platform/) → [Lab 03](./labs/03-cicd-pipelines/) → [Lab 04](./labs/04-observability-stack/) → [Lab 06](./labs/06-gitops-workflows/)

**Skills Gained**:
- Infrastructure as Code mastery
- Kubernetes platform management
- CI/CD pipeline automation
- Production monitoring and observability
- GitOps deployment strategies

**Career Fit**: DevOps Engineer, Cloud Engineer, SRE, Platform Engineer

---

### 🔒 **DevSecOps Engineer** 
*Security-focused path with automation emphasis*

**Path**: [Lab 01](./labs/01-terraform-foundations/) → [Lab 03](./labs/03-cicd-pipelines/) → [Lab 05](./labs/05-security-automation/) → [Lab 04](./labs/04-observability-stack/) → [Lab 06](./labs/06-gitops-workflows/)

**Skills Gained**:
- Secure infrastructure design
- Automated security scanning
- Policy as code implementation
- Security monitoring and alerting
- Compliance automation

**Career Fit**: DevSecOps Engineer, Security Engineer, Compliance Engineer

---

### 🏗️ **Platform Engineer**
*Build internal platforms and developer experiences*

**Path**: [Lab 01](./labs/01-terraform-foundations/) → [Lab 02](./labs/02-kubernetes-platform/) → [Lab 06](./labs/06-gitops-workflows/) → [Lab 08](./labs/08-platform-engineering/) → [Lab 04](./labs/04-observability-stack/)

**Skills Gained**:
- Internal platform design
- Developer self-service platforms
- Crossplane for infrastructure APIs
- Backstage developer portals
- Platform observability

**Career Fit**: Platform Engineer, Developer Experience Engineer, Infrastructure Architect

---

### ☁️ **Cloud Architect**
*Infrastructure design and serverless patterns*

**Path**: [Lab 01](./labs/01-terraform-foundations/) → [Lab 07](./labs/07-serverless-ops/) → [Lab 02](./labs/02-kubernetes-platform/) → [Lab 04](./labs/04-observability-stack/) → [Lab 08](./labs/08-platform-engineering/)

**Skills Gained**:
- Multi-tier architecture design
- Serverless and event-driven patterns
- Cost optimization strategies
- Hybrid cloud deployments
- Enterprise architecture patterns

**Career Fit**: Cloud Architect, Solutions Architect, Principal Engineer

---

### 🎓 **Complete DevOps Mastery**
*Comprehensive coverage of all DevOps domains*

**Path**: Complete all labs in order: [01](./labs/01-terraform-foundations/) → [02](./labs/02-kubernetes-platform/) → [03](./labs/03-cicd-pipelines/) → [04](./labs/04-observability-stack/) → [05](./labs/05-security-automation/) → [06](./labs/06-gitops-workflows/) → [07](./labs/07-serverless-ops/) → [08](./labs/08-platform-engineering/)

**Time Investment**: 8-12 hours total  
**Skills Gained**: Full-stack DevOps expertise across all major domains  
**Career Fit**: Senior DevOps Engineer, Principal Engineer, Technical Lead

---

## Getting Started

### Quick Environment Check

```bash
# Clone the repository
git clone https://github.com/WBHankins93/devops-studio.git
cd devops-studio

# Check if you have required tools
./tools/validate.sh

# Set up your environment
./tools/setup.sh
```

### Choose Your First Lab

**New to DevOps?** → Start with [Lab 01 - Terraform Foundations](./labs/01-terraform-foundations/)

**Have Terraform experience?** → Jump to [Lab 02 - Kubernetes Platform](./labs/02-kubernetes-platform/)

**Want CI/CD focus?** → Begin with [Lab 03 - CI/CD Pipelines](./labs/03-cicd-pipelines/)

**Security focused?** → Start [Lab 01](./labs/01-terraform-foundations/) then [Lab 05](./labs/05-security-automation/)

Each lab includes detailed setup instructions and prerequisites specific to that technology stack.

---

## Prerequisites

### Required Tools

| Tool | Version | Purpose | Installation |
|------|---------|---------|--------------|
| **AWS CLI** | 2.0+ | AWS resource management | [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| **Terraform** | 1.5+ | Infrastructure provisioning | [Install Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) |
| **kubectl** | 1.28+ | Kubernetes management | [Install Guide](https://kubernetes.io/docs/tasks/tools/) |
| **Helm** | 3.10+ | Kubernetes package management | [Install Guide](https://helm.sh/docs/intro/install/) |
| **Docker** | 20.0+ | Container management | [Install Guide](https://docs.docker.com/get-docker/) |
| **Git** | 2.0+ | Version control | [Install Guide](https://git-scm.com/downloads) |

### AWS Account Requirements

- **AWS Account** with billing enabled ([Create Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/))
- **IAM User** with programmatic access
- **Required Permissions**:
  - EC2 Full Access
  - VPC Full Access  
  - RDS Full Access
  - EKS Full Access
  - IAM permissions for roles and policies
  - CloudWatch Full Access
  - S3 Full Access
  - DynamoDB Full Access

### System Requirements

- **Operating System**: macOS, Linux, or Windows WSL2
- **Memory**: 8GB+ recommended (4GB minimum)
- **Disk Space**: 10GB+ free space
- **Network**: Reliable internet connection for AWS API calls

### Knowledge Prerequisites

**Essential (before starting)**:
- Basic command line usage
- Understanding of cloud computing concepts
- Git fundamentals

**Helpful (will learn as you go)**:
- AWS basics (EC2, VPC, IAM)
- Container concepts (Docker basics)
- Infrastructure as Code principles

---

## Quick Start Guide

### Option 1: Interactive Setup (Recommended)

```bash
# Clone and enter the repository
git clone https://github.com/WBHankins93/devops-studio.git
cd devops-studio

# Run interactive setup
./tools/setup.sh

# Follow the prompts to:
# 1. Validate required tools
# 2. Configure AWS credentials  
# 3. Choose your first lab
# 4. Set up that lab's environment
```

### Option 2: Manual Setup

```bash
# 1. Verify tools are installed
aws --version
terraform --version
kubectl version --client
docker --version

# 2. Configure AWS CLI
aws configure

# 3. Verify AWS access
aws sts get-caller-identity

# 4. Choose and start your first lab
cd labs/01-terraform-foundations
make apply
```

### Option 3: Specific Lab Direct Start

```bash
# Go directly to a specific lab
cd labs/01-terraform-foundations

# Follow that lab's README for setup
cat README.md

# Use the lab's automation
make apply
```

---

## Platform Features

### For Learners

- **🎯 Progressive Complexity**: Start simple, build to advanced concepts
- **🧪 Hands-On Experience**: Deploy real infrastructure, not just theory
- **💡 Real-World Context**: Understand why, not just how
- **📚 Comprehensive Docs**: Clear explanations and troubleshooting guides
- **💰 Cost Conscious**: Designed for learning budgets with cleanup automation
- **🔄 Repeatable**: Destroy and rebuild as many times as needed

### For Professionals

- **📋 Reference Implementations**: Battle-tested configurations to adapt
- **⚡ Time-Saving**: Skip research, get straight to implementation
- **👥 Team Training**: Onboard new engineers faster with structured learning
- **🏆 Portfolio Enhancement**: Demonstrable skills with real deployments
- **🔧 Production Patterns**: Architecture patterns used in enterprise environments
- **📖 Documentation Templates**: Examples of clear technical communication

### For Organizations

- **🎓 Training Platform**: Structured learning for DevOps teams
- **📋 Best Practices**: Proven patterns for infrastructure and automation
- **🔒 Security First**: Examples of secure-by-design infrastructure
- **💵 Cost Management**: Understanding and controlling cloud costs
- **🚀 Rapid Prototyping**: Quick proof-of-concept deployments
- **📊 Skill Assessment**: Hands-on evaluation of technical capabilities

---

## Cost Considerations

### Estimated Monthly Costs by Lab

| Lab | Resources | Est. Cost (USD) | Free Tier Eligible |
|-----|-----------|-----------------|-------------------|
| **Lab 01** | VPC, ASG, RDS, ALB | $50-80 | Partially |
| **Lab 02** | + EKS cluster | $120-180 | No |
| **Lab 04** | + Monitoring stack | $140-200 | No |
| **All Labs** | Complete platform | $200-300 | No |

### Cost Optimization Strategies

#### For Learning/Development
```bash
# Scale resources to minimum
terraform apply -var="desired_capacity=1" -var="instance_type=t3.micro"

# Use single AZ for non-HA scenarios  
terraform apply -var="availability_zones=[\"us-west-2a\"]"

# Clean up when not in use
make destroy  # Per lab
./tools/cleanup.sh  # All labs
```

#### For Production Reference
- Use Reserved Instances for predictable workloads
- Implement auto-scaling policies for cost optimization
- Regular right-sizing analysis with AWS Cost Explorer
- Tagging strategy for cost allocation and tracking

### Budget Alerts

Set up AWS Budget alerts to prevent unexpected charges:

```bash
# Create a budget alert (one-time setup)
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://budget-alert.json
```

---

## Troubleshooting

### Common Setup Issues

#### AWS CLI Not Configured
```bash
# Error: Unable to locate credentials
# Solution: Configure AWS CLI
aws configure
aws sts get-caller-identity
```

#### Insufficient Permissions
```bash
# Error: User: arn:aws:iam::xxx:user/xxx is not authorized
# Solution: Attach required policies to your IAM user
# See Prerequisites section for required permissions
```

#### Tool Version Conflicts
```bash
# Error: Terraform version is incompatible
# Solution: Update to required version
terraform --version  # Check current version
# Install latest from: https://terraform.io/downloads
```

#### Port Conflicts
```bash
# Error: Port already in use
# Solution: Check what's using the port
lsof -i :8080
# Kill the process or use different port
```

### Lab-Specific Issues

#### Terraform State Conflicts
```bash
# Error: Error acquiring the state lock
# Solution: Force unlock (use carefully)
terraform force-unlock <lock-id>

# Or check DynamoDB table for stuck locks
aws dynamodb scan --table-name devops-studio-terraform-locks
```

#### AWS Resource Limits
```bash
# Error: Service quota exceeded
# Solution: Check current limits
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-34B43A08  # Running On-Demand instances

# Request quota increase if needed
```

#### Cost Overruns
```bash
# Emergency cleanup all resources
./tools/cleanup.sh

# Check for running resources
aws ec2 describe-instances --query 'Reservations[*].Instances[?State.Name==`running`]'
aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus==`available`]'
```

### Getting Help

1. **Check lab-specific README**: Each lab has detailed troubleshooting
2. **Review [troubleshooting docs](./docs/troubleshooting.md)**: Common platform issues
3. **Check AWS service status**: [AWS Health Dashboard](https://health.aws.amazon.com/health/status)
4. **Enable debug logging**: `export TF_LOG=DEBUG` for Terraform issues
5. **Create an issue**: [GitHub Issues](https://github.com/WBHankins93/devops-studio/issues) for bugs or questions

---

## Contributing

We welcome contributions! This platform grows stronger with community input.

### Ways to Contribute

- 🐛 **Bug Reports**: Found an issue? [Create an issue](https://github.com/WBHankins93/devops-studio/issues)
- ✨ **Feature Requests**: Have an idea? [Start a discussion](https://github.com/WBHankins93/devops-studio/discussions)
- 📝 **Documentation**: Improve explanations or add missing docs
- 🧪 **New Labs**: Contribute additional learning scenarios
- 🔧 **Bug Fixes**: Submit pull requests for fixes
- 📊 **Testing**: Help validate labs in different environments

### Contribution Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-lab`)
3. **Test** your changes thoroughly
4. **Document** your additions
5. **Submit** a pull request with clear description

See [CONTRIBUTING.md](./CONTRIBUTING.md) for detailed guidelines.

### Lab Contribution Guidelines

When contributing new labs:
- Follow the established directory structure
- Include comprehensive README with setup/cleanup
- Add cost estimates and optimization tips
- Provide troubleshooting section
- Test in multiple environments
- Include validation scripts

---

## Additional Resources

### Documentation

- **[Getting Started Guide](./docs/getting-started.md)** - Detailed setup instructions
- **[Prerequisites Guide](./docs/prerequisites.md)** - System requirements breakdown  
- **[Troubleshooting Guide](./docs/troubleshooting.md)** - Common issues and solutions
- **[Architecture Decisions](./docs/architecture-decisions/)** - Why we made certain design choices

### Learning Resources

- **[AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)** - AWS best practices
- **[Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)** - Infrastructure as Code standards
- **[Kubernetes Documentation](https://kubernetes.io/docs/home/)** - Container orchestration guide
- **[CNCF Landscape](https://landscape.cncf.io/)** - Cloud Native technology ecosystem

### Community Resources

- **[AWS Community](https://aws.amazon.com/developer/community/)** - AWS user community
- **[Terraform Community](https://discuss.hashicorp.com/c/terraform-core/)** - Terraform discussions
- **[CNCF Community](https://www.cncf.io/community/)** - Cloud Native community
- **[DevOps Subreddit](https://www.reddit.com/r/devops/)** - DevOps discussions

### Tools and Extensions

- **[AWS CLI](https://aws.amazon.com/cli/)** - Command line interface for AWS
- **[Terraform](https://terraform.io/)** - Infrastructure as Code
- **[kubectl](https://kubernetes.io/docs/reference/kubectl/)** - Kubernetes CLI
- **[Helm](https://helm.sh/)** - Kubernetes package manager
- **[infracost](https://www.infracost.io/)** - Cost estimation for Terraform
- **[tfsec](https://github.com/aquasecurity/tfsec)** - Security scanning for Terraform

---

## Support

### Community Support

- **💬 [GitHub Discussions](https://github.com/WBHankins93/devops-studio/discussions)** - Community Q&A
- **🐛 [GitHub Issues](https://github.com/WBHankins93/devops-studio/issues)** - Bug reports and feature requests
- **📧 [Email](mailto:benhankins.work@gmail.com)** - Direct contact for complex issues

### Professional Services

For organizations looking to implement these patterns in production environments:

- **Architecture Review**: Infrastructure design consultation
- **Team Training**: Custom workshops based on these labs
- **Implementation Support**: Guided deployment assistance
- **Custom Lab Development**: Tailored scenarios for specific needs

### Acknowledgments

This platform builds on the incredible work of the open-source community:

- **HashiCorp** for Terraform
- **Kubernetes** community for container orchestration
- **AWS** for comprehensive cloud services
- **CNCF** for advancing cloud-native technologies

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**🚀 Ready to start your DevOps journey?**

Begin with [Lab 01 - Terraform Foundations](./labs/01-terraform-foundations/) and build production-ready infrastructure in under an hour!

**Questions?** Check our [FAQ](./docs/troubleshooting.md#frequently-asked-questions) or [start a discussion](https://github.com/WBHankins93/devops-studio/discussions).

---

*Built with ❤️ for the DevOps community*