# Lab 03 - CI/CD Pipelines
*Automating Build, Test, and Deployment with GitHub Actions, GitLab CI, and Jenkins*

> **Navigation**: [DevOps Studio](../../README.md) > [Labs](../README.md) > Lab 03  
> **Previous Lab**: [Lab 02 - Kubernetes Platform](../02-kubernetes-platform/README.md)  
> **Next Lab**: [Lab 04 - Observability Stack](../04-observability-stack/README.md)

[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![GitLab CI](https://img.shields.io/badge/GitLab_CI-FC6D26?logo=gitlab&logoColor=white)](https://docs.gitlab.com/ee/ci/)
[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io)

> **Objective**: Build comprehensive CI/CD pipelines using GitHub Actions, GitLab CI, and Jenkins. Learn to automate testing, container image building, security scanning, and deployments to Kubernetes. This lab demonstrates real-world DevOps automation patterns used in production environments.

---

## 📑 Table of Contents

- [Overview](#overview)
- [What You'll Learn](#what-youll-learn)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Project Structure](#project-structure)
- [GitHub Actions](#github-actions)
- [GitLab CI](#gitlab-ci)
- [Jenkins](#jenkins)
- [Testing & Validation](#testing--validation)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Learning Objectives](#learning-objectives)
- [Best Practices Demonstrated](#best-practices-demonstrated)
- [Cost Considerations](#cost-considerations)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

---

## Overview

This lab provides complete CI/CD pipeline implementations using three popular tools: GitHub Actions, GitLab CI, and Jenkins. You'll learn how to automate the entire software delivery lifecycle from code commit to production deployment.

### What Gets Built

- **Sample Application** with Dockerfile and tests
- **GitHub Actions Workflows** for CI/CD
- **GitLab CI Pipeline** configuration
- **Jenkins Pipeline** (Jenkinsfile)
- **Docker Image Building** and registry management
- **Automated Testing** (unit, integration, security)
- **Security Scanning** (Trivy, Snyk)
- **Kubernetes Deployment** automation
- **Multi-environment** deployment strategies

### Key Features

- ✅ **Multiple CI/CD Tools**: GitHub Actions, GitLab CI, Jenkins
- ✅ **Production Patterns**: Real enterprise-grade pipeline configurations
- ✅ **Security Integration**: Automated vulnerability scanning
- ✅ **Multi-Environment**: Dev, staging, and production deployments
- ✅ **Kubernetes Integration**: Deploy to EKS cluster from Lab 02
- ✅ **Well Documented**: Clear explanations and examples

---

## What You'll Learn

### CI/CD Fundamentals
- Continuous Integration concepts
- Continuous Deployment vs Continuous Delivery
- Pipeline as Code
- Build automation
- Test automation

### GitHub Actions
- Workflow syntax and structure
- Jobs, steps, and actions
- Matrix builds and parallelization
- Secrets management
- Artifact management

### GitLab CI
- `.gitlab-ci.yml` configuration
- Stages and jobs
- Runners and executors
- CI/CD variables
- Pipeline artifacts

### Jenkins
- Jenkinsfile (declarative and scripted)
- Pipeline stages
- Shared libraries
- Jenkins agents
- Plugin management

### Container Workflows
- Docker image building
- Multi-stage builds
- Image scanning
- Registry management
- Image tagging strategies

### Kubernetes Deployment
- kubectl in CI/CD
- Helm chart deployment
- Rolling updates
- Blue-green deployments
- Canary releases

### Security in CI/CD
- Vulnerability scanning
- Secret scanning
- SAST/DAST integration
- Policy enforcement
- Compliance checks

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Source Code                               │
│                    (Git Repository)                              │
└─────────────────────────┬───────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   GitHub     │  │   GitLab     │  │   Jenkins    │
│   Actions    │  │     CI       │  │   Pipeline   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       └─────────────────┼─────────────────┘
                         │
              ┌──────────┴──────────┐
              │                    │
              ▼                    ▼
      ┌──────────────┐    ┌──────────────┐
      │   Build &    │    │   Security   │
      │    Test      │    │   Scanning   │
      └──────┬───────┘    └──────┬───────┘
             │                   │
             └──────────┬─────────┘
                        │
                        ▼
              ┌─────────────────┐
              │  Docker Build   │
              │  & Push to ECR  │
              └────────┬────────┘
                       │
                       ▼
              ┌─────────────────┐
              │   Deploy to     │
              │   Kubernetes    │
              │   (Lab 02 EKS)  │
              └─────────────────┘
```

### Pipeline Stages

1. **Source**: Code in Git repository
2. **Build**: Compile, build Docker images
3. **Test**: Unit tests, integration tests
4. **Scan**: Security and vulnerability scanning
5. **Deploy**: Deploy to Kubernetes cluster
6. **Verify**: Health checks and smoke tests

---

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **Docker** | 20.0+ | Container image building |
| **Git** | 2.0+ | Version control |
| **kubectl** | 1.28+ | Kubernetes deployment |
| **Helm** | 3.10+ | Kubernetes package management |

### AWS Requirements

- **AWS Account** with billing enabled
- **ECR (Elastic Container Registry)** access
- **EKS Cluster** from Lab 02 (optional but recommended)

### Knowledge Prerequisites

- Basic Git workflow
- Docker fundamentals
- Kubernetes basics (from Lab 02)
- Understanding of CI/CD concepts

### Lab Dependencies

**Recommended**: Complete [Lab 02](../02-kubernetes-platform/) first to have an EKS cluster for deployments.

---

## Quick Start

For experienced users who want to set up CI/CD immediately:

```bash
# 1. Navigate to lab directory
cd labs/03-cicd-pipelines

# 2. Choose your CI/CD tool
# Option A: GitHub Actions (recommended for GitHub repos)
cp github-actions/.github/workflows/ci-cd.yml ../../.github/workflows/

# Option B: GitLab CI
# Copy .gitlab-ci.yml to your GitLab repository root

# Option C: Jenkins
# Set up Jenkins and use the Jenkinsfile

# 3. Configure secrets/variables
# GitHub: Repository Settings > Secrets
# GitLab: CI/CD > Variables
# Jenkins: Credentials

# 4. Push code to trigger pipeline
git add .
git commit -m "Add CI/CD pipeline"
git push
```

**Setup time**: ~10-15 minutes  
**Estimated cost**: $1-2 to complete (vs $20-40/month if kept running)

---

## Detailed Setup

### Step 1: Choose Your CI/CD Tool

This lab supports three CI/CD platforms:

1. **GitHub Actions** - Best for GitHub repositories
2. **GitLab CI** - Best for GitLab repositories
3. **Jenkins** - Best for self-hosted or on-premises

You can use one or all of them. Each has complete examples.

### Step 2: Sample Application Setup

The lab includes a sample application:

```bash
cd labs/03-cicd-pipelines
ls -la app/
```

### Step 3: Configure CI/CD Platform

Follow the specific setup instructions for your chosen platform in the sections below.

---

## Project Structure

```
labs/03-cicd-pipelines/
├── README.md                    # This file
├── Makefile                     # Automation commands
├── app/                         # Sample application
│   ├── Dockerfile              # Container image definition
│   ├── src/                    # Application source code
│   ├── tests/                  # Test files
│   └── package.json            # Dependencies
├── github-actions/             # GitHub Actions workflows
│   └── .github/
│       └── workflows/
│           ├── ci.yml         # Continuous Integration
│           ├── cd.yml         # Continuous Deployment
│           └── security.yml   # Security scanning
├── gitlab-ci/                  # GitLab CI configuration
│   └── .gitlab-ci.yml         # GitLab CI pipeline
├── jenkins/                    # Jenkins pipelines
│   └── Jenkinsfile            # Jenkins pipeline definition
├── k8s/                        # Kubernetes manifests
│   ├── deployment.yaml        # Application deployment
│   ├── service.yaml           # Service definition
│   └── ingress.yaml           # Ingress configuration
└── scripts/                    # Automation scripts
    ├── build.sh               # Build script
    ├── test.sh                # Test script
    └── deploy.sh              # Deployment script
```

---

## GitHub Actions

### Workflow Overview

GitHub Actions workflows are defined in `.github/workflows/` directory.

### CI Workflow

The CI workflow runs on every push and pull request:

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: ./scripts/test.sh
```

### CD Workflow

The CD workflow deploys to Kubernetes:

```yaml
name: CD Pipeline

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Kubernetes
        run: ./scripts/deploy.sh
```

### Setup Instructions

1. **Copy workflows to repository**:
   ```bash
   cp -r github-actions/.github ../../.github/
   ```

2. **Configure secrets** (Repository Settings > Secrets):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `KUBECONFIG` (base64 encoded)

3. **Push code** to trigger workflows

---

## GitLab CI

### Pipeline Overview

GitLab CI uses `.gitlab-ci.yml` in the repository root.

### Configuration

```yaml
stages:
  - build
  - test
  - security
  - deploy

build:
  stage: build
  script:
    - docker build -t app:latest .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

### Setup Instructions

1. **Copy `.gitlab-ci.yml`** to your GitLab repository root
2. **Configure CI/CD variables** (Settings > CI/CD > Variables):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `KUBECONFIG`
3. **Enable GitLab Runners** or use shared runners
4. **Push code** to trigger pipeline

---

## Jenkins

### Pipeline Overview

Jenkins uses a `Jenkinsfile` for pipeline as code.

### Setup Instructions

1. **Install Jenkins** (local or server)
2. **Install required plugins**:
   - Pipeline
   - Docker Pipeline
   - Kubernetes
   - Git
3. **Configure credentials**:
   - AWS credentials
   - Docker registry credentials
   - Kubernetes kubeconfig
4. **Create pipeline** from Jenkinsfile
5. **Trigger builds** manually or via webhooks

---

## Testing & Validation

### Automated Tests

The lab includes automated testing:

```bash
# Run tests locally
./scripts/test.sh

# Run in CI/CD
# Tests run automatically in pipelines
```

### Test Types

- **Unit Tests**: Application logic
- **Integration Tests**: Component integration
- **Security Tests**: Vulnerability scanning
- **Smoke Tests**: Post-deployment validation

---

## Deployment

### Kubernetes Deployment

Deploy to the EKS cluster from Lab 02:

```bash
# Configure kubectl (if not already done)
cd ../02-kubernetes-platform
make configure-kubectl

# Deploy application
cd ../03-cicd-pipelines
kubectl apply -f k8s/
```

### Deployment Strategies

- **Rolling Update**: Default Kubernetes strategy
- **Blue-Green**: Using multiple deployments
- **Canary**: Gradual rollout

---

## Troubleshooting

### Common Issues

#### Pipeline Fails on Build
```bash
# Check Docker build locally
docker build -t test-app .

# Check Dockerfile syntax
docker build --no-cache -t test-app .
```

#### Deployment Fails
```bash
# Check cluster access
kubectl cluster-info

# Check deployment status
kubectl get deployments
kubectl describe deployment <deployment-name>
```

#### Secrets Not Found
- Verify secrets are configured in CI/CD platform
- Check secret names match workflow references
- Ensure secrets have correct permissions

---

## Cleanup

### Remove Deployed Resources

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete Docker images from ECR
aws ecr list-images --repository-name <repo-name>
aws ecr batch-delete-image --repository-name <repo-name> --image-ids ...
```

---

## Learning Objectives

### Beginner Level ✅
After completing this lab, you should understand:
- CI/CD pipeline concepts
- Basic GitHub Actions/GitLab CI/Jenkins usage
- Docker image building
- Automated testing in pipelines

### Intermediate Level ✅
You should be able to:
- Design multi-stage pipelines
- Integrate security scanning
- Deploy to Kubernetes automatically
- Manage secrets securely

### Advanced Level ✅
You should master:
- Pipeline optimization
- Multi-environment deployments
- Advanced deployment strategies
- Pipeline monitoring and observability

---

## Best Practices Demonstrated

### CI/CD
- ✅ **Pipeline as Code**: Version controlled pipelines
- ✅ **Automated Testing**: Tests run on every change
- ✅ **Security Scanning**: Automated vulnerability detection
- ✅ **Multi-Stage**: Build, test, scan, deploy stages

### Security
- ✅ **Secrets Management**: Secure credential handling
- ✅ **Image Scanning**: Container vulnerability scanning
- ✅ **Least Privilege**: Minimal required permissions
- ✅ **Audit Trail**: Complete pipeline history

---

## Cost Considerations

### Estimated Costs

**Monthly Cost** (if running continuously): ~$20-40
- CI/CD Runner costs: $10-20/month
- ECR storage: $5-10/month
- Kubernetes resources: $5-10/month

**Cost to Complete** (run pipelines for 1-2 hours): ~$1-2
- Pipeline execution: Minimal (mostly compute time)
- ECR storage: Negligible for small images
- Kubernetes deployment: Included in Lab 02 costs

### Cost Optimization

- Use GitHub Actions free tier (2000 minutes/month for private repos)
- Use GitLab shared runners (free tier available)
- Clean up old Docker images regularly
- Destroy test deployments immediately

---

## Next Steps

### Immediate Next Actions
1. **Set up a CI/CD tool** and configure workflows
2. **Test the pipeline** with sample commits
3. **Deploy to Kubernetes** and verify
4. **Experiment** with different deployment strategies

### Continue Your Learning Journey

#### Next Recommended Lab
- **[Lab 04 - Observability Stack](../04-observability-stack/README.md)** - Monitor your CI/CD deployments

#### Related Labs
- **[Lab 02: Kubernetes Platform](../02-kubernetes-platform/README.md)** - Deploy to this cluster
- **[Lab 06: GitOps Workflows](../06-gitops-workflows/README.md)** - Advanced GitOps patterns

---

## Additional Resources

### Documentation
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitLab CI Docs](https://docs.gitlab.com/ee/ci/)
- [Jenkins Docs](https://www.jenkins.io/doc/)

### Learning Resources
- [CI/CD Best Practices](https://www.redhat.com/en/topics/devops/what-is-ci-cd)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**🎉 Congratulations!** You've completed Lab 03 and built automated CI/CD pipelines. Your code changes now automatically build, test, and deploy!

**Ready for the next challenge?** Continue to [Lab 04 - Observability Stack](../04-observability-stack/) to monitor your deployments!

