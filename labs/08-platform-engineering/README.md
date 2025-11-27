# Lab 08 - Platform Engineering
*Building Internal Developer Platforms for Self-Service Infrastructure*

> **Navigation**: [DevOps Studio](../../README.md) > [Labs](../README.md) > Lab 08  
> **Previous Lab**: [Lab 07 - Serverless Operations](../07-serverless-operations/README.md)

[![Platform Engineering](https://img.shields.io/badge/Platform%20Engineering-FF6B6B?logo=kubernetes)](https://platformengineering.org/)
[![Backstage](https://img.shields.io/badge/Backstage-9BF0E1?logo=backstage)](https://backstage.io/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform)](https://www.terraform.io/)

> **Objective**: Master Platform Engineering by building an Internal Developer Platform (IDP) that enables self-service infrastructure provisioning, service catalogs, developer portals, and automated workflows. Learn to create a platform that empowers developers while maintaining governance and best practices.

---

## 📑 Table of Contents

- [Overview](#overview)
- [What is Platform Engineering?](#what-is-platform-engineering)
- [Internal Developer Platform (IDP) Concepts](#internal-developer-platform-idp-concepts)
- [What You'll Learn](#what-youll-learn)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Step-by-Step Tutorials](#step-by-step-tutorials)
- [Advanced Patterns](#advanced-patterns)
- [Monitoring and Metrics](#monitoring-and-metrics)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Learning Objectives](#learning-objectives)
- [Best Practices Demonstrated](#best-practices-demonstrated)
- [Cost Considerations](#cost-considerations)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

---

## Overview

This lab provides a comprehensive introduction to Platform Engineering. You'll build an Internal Developer Platform (IDP) that enables developers to provision infrastructure, discover services, and manage applications through self-service capabilities.

### What Gets Built

- **Developer Portal** - Central hub for developers
- **Service Catalog** - Pre-configured infrastructure templates
- **Self-Service Provisioning** - Automated infrastructure deployment
- **CI/CD Integration** - Automated pipeline creation
- **Monitoring Dashboard** - Platform health and metrics
- **Documentation Hub** - Centralized documentation
- **API Gateway** - Platform APIs for automation

### Key Features

- ✅ **Self-Service** - Developers provision infrastructure independently
- ✅ **Service Catalog** - Pre-approved infrastructure templates
- ✅ **Governance** - Built-in policies and guardrails
- ✅ **Automation** - Automated workflows and pipelines
- ✅ **Observability** - Platform metrics and health monitoring
- ✅ **Production Ready** - Enterprise-grade platform patterns

---

## What is Platform Engineering?

### Definition

**Platform Engineering** is the discipline of designing and building toolchains and workflows that enable self-service capabilities for software engineering organizations. The goal is to improve developer experience and productivity by providing a curated set of tools, capabilities, and processes.

### The Evolution

**Traditional DevOps**:
- Developers request infrastructure
- DevOps team manually provisions
- Long wait times
- Inconsistent configurations

**Platform Engineering**:
- Developers self-serve infrastructure
- Automated provisioning with templates
- Instant availability
- Consistent, governed configurations

### Key Principles

1. **Self-Service** - Developers can provision without waiting
2. **Golden Paths** - Pre-approved, best-practice templates
3. **Guardrails** - Safety without blocking innovation
4. **Developer Experience** - Easy to use, well-documented
5. **Observability** - Visibility into platform usage

### Benefits

- **Faster Time to Market** - Developers deploy faster
- **Consistency** - Standardized infrastructure
- **Governance** - Built-in compliance and security
- **Cost Optimization** - Better resource utilization
- **Developer Satisfaction** - Better developer experience

---

## Internal Developer Platform (IDP) Concepts

### What is an IDP?

An **Internal Developer Platform (IDP)** is a set of tools, services, and workflows that enable developers to build, deploy, and operate applications independently, without requiring deep infrastructure knowledge.

### Core Components

1. **Developer Portal** - Single entry point for all developer needs
2. **Service Catalog** - Pre-configured infrastructure templates
3. **Self-Service APIs** - APIs for automated provisioning
4. **CI/CD Platform** - Automated build and deployment
5. **Observability** - Monitoring, logging, and metrics
6. **Documentation** - Centralized knowledge base

### Platform Layers

```
┌─────────────────────────────────────┐
│     Developer Experience Layer      │
│  (Portal, CLI, APIs, Documentation) │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Platform Services Layer        │
│  (Provisioning, CI/CD, Monitoring)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Infrastructure Layer           │
│  (AWS, Kubernetes, Terraform)      │
└─────────────────────────────────────┘
```

### Golden Paths

**Golden Paths** are pre-approved, well-tested infrastructure templates that represent best practices. Examples:

- **Web Application** - Standard web app template (ALB, ASG, RDS)
- **API Service** - API template (API Gateway, Lambda)
- **Data Pipeline** - ETL template (Glue, S3, Redshift)
- **Container Service** - Kubernetes template (EKS, Deployment)

### Guardrails

**Guardrails** are automated policies that ensure compliance:

- **Security** - Encryption, IAM policies, network isolation
- **Cost** - Budget limits, resource tagging
- **Compliance** - Regulatory requirements
- **Best Practices** - Naming conventions, resource limits

---

## What You'll Learn

### Platform Engineering Fundamentals
- Understanding Platform Engineering vs DevOps
- IDP architecture and design
- Self-service capabilities
- Developer experience principles

### Developer Portal
- Portal setup and configuration
- Service catalog creation
- Documentation integration
- Developer onboarding

### Service Catalog
- Template creation
- Infrastructure as Code templates
- Parameter validation
- Version management

### Self-Service Provisioning
- Automated infrastructure deployment
- Terraform automation
- Approval workflows
- Resource management

### CI/CD Platform
- Pipeline templates
- Automated pipeline creation
- Multi-environment support
- Deployment automation

### Monitoring and Observability
- Platform metrics
- Usage analytics
- Cost tracking
- Health monitoring

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Developer Portal                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Service    │  │  Provision   │  │  Monitor    │      │
│  │   Catalog    │  │  Infrastructure│ │  Resources  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────┬───────────────────────────────────┘
                            │
┌───────────────────────────▼───────────────────────────────────┐
│                  Platform API Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Provisioning│  │   CI/CD      │  │  Monitoring  │      │
│  │    API      │  │    API       │  │     API      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────┬───────────────────────────────────┘
                            │
┌───────────────────────────▼───────────────────────────────────┐
│              Infrastructure Automation Layer                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Terraform   │  │   GitHub    │  │  CloudWatch  │      │
│  │  Automation  │  │   Actions   │  │   Metrics    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└──────────────────────────┬───────────────────────────────────┘
                            │
┌───────────────────────────▼───────────────────────────────────┐
│                    AWS Infrastructure                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │     VPC      │  │     EKS      │  │   Lambda     │      │
│  │   EC2/ASG    │  │   RDS        │  │   S3/DynamoDB │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

```
Developer → Portal → Service Catalog → Select Template
    ↓
Portal → Platform API → Terraform Automation
    ↓
Terraform → AWS → Provision Infrastructure
    ↓
Platform API → CI/CD → Create Pipeline
    ↓
Monitoring → Dashboard → Track Usage
```

---

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **AWS CLI** | 2.0+ | AWS service management |
| **Terraform** | 1.5+ | Infrastructure as Code |
| **Docker** | 20.10+ | Container runtime |
| **kubectl** | 1.28+ | Kubernetes management |
| **Node.js** | 18+ | Portal development |
| **Python** | 3.9+ | Automation scripts |

### AWS Requirements

- **AWS Account** with appropriate permissions
- **EKS Cluster** from Lab 02 (or existing cluster)
- **IAM User/Role** with platform permissions

### Knowledge Prerequisites

- Understanding of Labs 01-07
- Basic Kubernetes knowledge
- Terraform experience
- API design concepts

### Lab Dependencies

**Recommended**: Complete previous labs, especially:
- [Lab 01: Terraform Foundations](../01-terraform-foundations/)
- [Lab 02: Kubernetes Platform](../02-kubernetes-platform/)
- [Lab 06: GitOps Workflows](../06-gitops-workflows/)

---

## Quick Start

For experienced users who want to deploy immediately:

```bash
# 1. Navigate to lab directory
cd labs/08-platform-engineering

# 2. Configure environment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Initialize and deploy
make init
make deploy

# 4. Access portal
make portal-url
```

**Setup time**: ~45-60 minutes  
**Estimated cost**: $5-10 to complete (vs $80-120/month if kept running)

---

## Detailed Setup

### Step 1: Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure

# Verify access
aws sts get-caller-identity
```

### Step 2: Set Up Environment Variables

```bash
# Create terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
# - project_name
# - aws_region
# - eks_cluster_name (from Lab 02)
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Review and Deploy

```bash
# Review plan
terraform plan

# Deploy platform
terraform apply
```

---

## Project Structure

```
labs/08-platform-engineering/
├── README.md                    # This file
├── Makefile                     # Automation commands
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output values
├── portal/                      # Developer portal
│   ├── README.md
│   ├── docker-compose.yml
│   └── config/
├── service-catalog/             # Service catalog templates
│   ├── README.md
│   ├── web-app/                # Web application template
│   ├── api-service/            # API service template
│   └── data-pipeline/          # Data pipeline template
├── platform-api/                # Platform APIs
│   ├── README.md
│   ├── provisioning/           # Provisioning API
│   └── monitoring/             # Monitoring API
├── automation/                  # Automation scripts
│   ├── terraform-runner/       # Terraform automation
│   └── ci-cd-generator/        # CI/CD pipeline generator
├── monitoring/                  # Platform monitoring
│   ├── dashboards/
│   └── metrics/
└── scripts/                     # Utility scripts
    ├── validate.sh
    └── setup-portal.sh
```

---

## Core Components

### Developer Portal

The developer portal is the central hub where developers:
- Browse service catalog
- Provision infrastructure
- Monitor resources
- Access documentation
- View metrics and costs

**Technologies**: Backstage, Port, or custom portal

See [portal/README.md](portal/README.md) for detailed setup.

### Service Catalog

The service catalog contains pre-configured infrastructure templates:

- **Web Application** - Standard web app (ALB, ASG, RDS)
- **API Service** - REST API (API Gateway, Lambda)
- **Container Service** - Kubernetes service (EKS)
- **Data Pipeline** - ETL pipeline (Glue, S3)

Each template includes:
- Terraform code
- Parameter definitions
- Documentation
- Best practices

See [service-catalog/README.md](service-catalog/README.md) for details.

### Platform APIs

RESTful APIs that enable:
- Infrastructure provisioning
- Resource management
- CI/CD pipeline creation
- Monitoring and metrics

See [platform-api/README.md](platform-api/README.md) for details.

### Automation Layer

Automated workflows that:
- Execute Terraform plans
- Create CI/CD pipelines
- Validate configurations
- Enforce guardrails

See [automation/README.md](automation/README.md) for details.

---

## Step-by-Step Tutorials

### Tutorial 1: Provision Your First Service

**Objective**: Use the service catalog to provision a web application.

**Steps**:

1. **Access Portal**
   ```bash
   # Get portal URL
   terraform output portal_url
   ```

2. **Browse Catalog**
   - Navigate to Service Catalog
   - Select "Web Application" template

3. **Configure Parameters**
   - Application name
   - Environment (dev/staging/prod)
   - Instance type
   - Database size

4. **Provision**
   - Click "Provision"
   - Monitor progress
   - Access application URL

**What you learned**:
- Self-service provisioning
- Service catalog usage
- Parameter configuration

### Tutorial 2: Create CI/CD Pipeline

**Objective**: Automatically create a CI/CD pipeline for your service.

**Steps**:

1. **Select Service**
   - Choose provisioned service
   - Navigate to CI/CD section

2. **Configure Pipeline**
   - Source repository
   - Build commands
   - Deployment targets

3. **Generate Pipeline**
   - Click "Generate Pipeline"
   - Review generated pipeline
   - Commit to repository

**What you learned**:
- Automated pipeline creation
- CI/CD integration
- Multi-environment support

### Tutorial 3: Monitor Platform Usage

**Objective**: View platform metrics and usage.

**Steps**:

1. **Access Dashboard**
   - Navigate to Monitoring
   - View platform metrics

2. **Analyze Usage**
   - Services provisioned
   - Resource utilization
   - Cost tracking

3. **Set Alerts**
   - Configure budget alerts
   - Set usage thresholds

**What you learned**:
- Platform observability
- Usage analytics
- Cost management

---

## Advanced Patterns

### Pattern 1: Multi-Tenancy

Support multiple teams with:
- Namespace isolation
- Resource quotas
- Team-specific catalogs

### Pattern 2: Approval Workflows

Add approvals for:
- Production deployments
- High-cost resources
- Security-sensitive changes

### Pattern 3: Custom Templates

Create team-specific templates:
- Domain-specific services
- Custom configurations
- Team best practices

### Pattern 4: Cost Optimization

Automated cost optimization:
- Right-sizing recommendations
- Unused resource cleanup
- Reserved instance management

---

## Monitoring and Metrics

### Platform Metrics

Monitor:
- **Provisioning Rate** - Services created per day
- **Success Rate** - Successful vs failed provisions
- **Time to Provision** - Average provisioning time
- **Resource Utilization** - CPU, memory, storage
- **Cost per Service** - Cost tracking

### Developer Metrics

Track:
- **Active Developers** - Platform usage
- **Services per Developer** - Productivity
- **Time to First Deploy** - Developer experience
- **Support Tickets** - Platform issues

### Cost Metrics

Monitor:
- **Total Platform Cost** - Overall spending
- **Cost per Service** - Service-level costs
- **Cost Trends** - Spending patterns
- **Budget Alerts** - Cost thresholds

See [monitoring/README.md](monitoring/README.md) for detailed setup.

---

## Troubleshooting

### Common Issues

**Portal Not Accessible**:
- Check ingress configuration
- Verify DNS settings
- Check security groups

**Provisioning Fails**:
- Check Terraform logs
- Verify IAM permissions
- Review resource limits

**CI/CD Pipeline Issues**:
- Check GitHub Actions logs
- Verify repository access
- Review pipeline configuration

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

---

## Cleanup

### Remove All Resources

```bash
# Destroy platform
terraform destroy

# Or use Makefile
make destroy
```

**Important**: Always destroy resources when not in use to avoid costs!

---

## Learning Objectives

### Beginner Level ✅
After completing this lab, you should understand:
- What Platform Engineering is
- IDP concepts and benefits
- Self-service provisioning
- Service catalog basics

### Intermediate Level ✅
You should be able to:
- Set up a developer portal
- Create service catalog templates
- Build platform APIs
- Implement automation workflows

### Advanced Level ✅
You should master:
- Complete IDP architecture
- Multi-tenancy support
- Advanced automation patterns
- Platform observability
- Cost optimization strategies

---

## Best Practices Demonstrated

### Platform Design
- ✅ **Golden Paths** - Pre-approved templates
- ✅ **Guardrails** - Automated compliance
- ✅ **Self-Service** - Developer autonomy
- ✅ **Documentation** - Comprehensive guides

### Developer Experience
- ✅ **Easy Onboarding** - Simple first steps
- ✅ **Clear Documentation** - Well-documented APIs
- ✅ **Fast Feedback** - Quick provisioning
- ✅ **Visibility** - Transparent processes

### Governance
- ✅ **Policy Enforcement** - Automated policies
- ✅ **Cost Controls** - Budget limits
- ✅ **Security** - Built-in security
- ✅ **Compliance** - Regulatory compliance

---

## Cost Considerations

### Estimated Costs

**Monthly Cost** (if running continuously): ~$80-120
- Portal infrastructure: $30-50/month
- Platform APIs: $20-30/month
- Monitoring: $10-20/month
- Automation: $20-30/month

**Cost to Complete** (run for 3-4 hours): ~$5-10
- Portal deployment: Minimal
- API usage: Pay-per-request
- Monitoring: Included
- Infrastructure: Pay-per-use

### Cost Optimization

- Use spot instances for non-critical components
- Right-size portal infrastructure
- Monitor and optimize API usage
- Destroy test resources immediately

---

## Next Steps

### Immediate Next Actions
1. **Deploy the platform** and verify all components
2. **Create your first service** from the catalog
3. **Set up monitoring** and dashboards
4. **Document your platform** for your team

### Continue Your Learning Journey

#### You've Completed All Labs! 🎉
- **Lab 01**: Terraform Foundations
- **Lab 02**: Kubernetes Platform
- **Lab 03**: CI/CD Pipelines
- **Lab 04**: Observability Stack
- **Lab 05**: Security Automation
- **Lab 06**: GitOps Workflows
- **Lab 07**: Serverless Operations
- **Lab 08**: Platform Engineering

### Real-World Applications

Apply what you've learned to:
- Build internal developer platforms
- Enable self-service infrastructure
- Improve developer productivity
- Implement platform engineering practices

---

## Additional Resources

### Documentation
- [Platform Engineering Guide](https://platformengineering.org/)
- [Backstage Documentation](https://backstage.io/docs)
- [Internal Developer Platforms](https://internaldeveloperplatform.org/)

### Learning Resources
- [Platform Engineering Best Practices](https://platformengineering.org/blog)
- [Building IDPs](https://www.thoughtworks.com/insights/blog/platform-engineering)

---

**🎉 Congratulations!** You've completed all 8 labs and mastered the complete DevOps and Platform Engineering journey! You now have the skills to build production-ready platforms that enable self-service infrastructure, improve developer experience, and maintain governance and best practices.

**You're ready to build amazing platforms!** 🚀

