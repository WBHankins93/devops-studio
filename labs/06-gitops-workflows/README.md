# Lab 06 - GitOps Workflows
*Automated deployments with Kustomize, Argo CD, and Flux*

> **Navigation**: [DevOps Studio](../../README.md) > [Labs](../README.md) > Lab 06  
> **Previous Lab**: [Lab 05 - Security Automation](../05-security-automation/README.md)  
> **Next Lab**: [Lab 07 - Serverless Operations](../07-serverless-operations/README.md)

[![Kustomize](https://img.shields.io/badge/Kustomize-326CE5?logo=kubernetes)](https://kustomize.io/)
[![Argo CD](https://img.shields.io/badge/Argo%20CD-EF7B4D?logo=argo)](https://argo-cd.readthedocs.io/)
[![Flux](https://img.shields.io/badge/Flux-0B1229?logo=flux)](https://fluxcd.io/)

> **Objective**: Learn GitOps workflows using Kustomize for configuration management and Argo CD/Flux for automated deployments. Understand when to use each tool and how they work together to create a complete GitOps pipeline.

---

## 📑 Table of Contents

- [Overview](#overview)
- [Understanding the Tools](#understanding-the-tools)
- [What You'll Learn](#what-youll-learn)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Project Structure](#project-structure)
- [Kustomize](#kustomize)
- [Argo CD](#argo-cd)
- [Flux](#flux)
- [Tool Comparison](#tool-comparison)
- [Integration Examples](#integration-examples)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Learning Objectives](#learning-objectives)
- [Best Practices Demonstrated](#best-practices-demonstrated)
- [Cost Considerations](#cost-considerations)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

---

## Overview

This lab implements a complete GitOps workflow using three complementary tools:

- **Kustomize** - Configuration management (write and organize Kubernetes YAML)
- **Argo CD** - GitOps deployment with visual UI
- **Flux** - GitOps deployment with CLI focus

### What Gets Built

- **Kustomize Base & Overlays** - Environment-specific configurations
- **Argo CD Setup** - Visual GitOps deployment platform
- **Flux Setup** - Lightweight GitOps controller
- **GitOps Workflows** - Automated deployment pipelines
- **Multi-Environment Management** - Staging and production configurations

### Key Features

- ✅ **Configuration Management**: Kustomize for organizing YAML
- ✅ **Automated Deployments**: GitOps with Argo CD or Flux
- ✅ **Visual Dashboard**: Argo CD UI for monitoring
- ✅ **CLI-First Option**: Flux for platform engineers
- ✅ **Multi-Environment**: Staging and production overlays
- ✅ **Production Ready**: Enterprise-grade GitOps workflows

---

## Understanding the Tools

### The Two Phases of GitOps

**Important**: Kustomize and Argo CD/Flux serve different phases:

1. **Configuration Phase** (Kustomize) - Writing and organizing Kubernetes YAML
2. **Deployment Phase** (Argo CD/Flux) - Automatically deploying from Git to cluster

### Kustomize: The "Writer"

**Role**: Configuration Management / Templating

**What it does**:
- Helps write and organize Kubernetes YAML files
- Creates base configurations and environment-specific overlays
- Merges base + overlays to generate final YAML
- Template-free (just patches standard YAML)

**When to use**: When you need to manage multiple environments (staging, prod) without copy-pasting YAML.

### Argo CD: The "Deployer" (Visual)

**Role**: Continuous Delivery (GitOps) with UI

**What it does**:
- Watches Git repository for changes
- Automatically deploys to Kubernetes cluster
- Provides visual dashboard for monitoring
- Centralized service for managing deployments

**When to use**: When you want a visual dashboard and need to troubleshoot deployments interactively.

### Flux: The "Deployer" (CLI)

**Role**: Continuous Delivery (GitOps) without UI

**What it does**:
- Watches Git repository for changes
- Automatically deploys to Kubernetes cluster
- CLI-focused, lightweight automation
- Modular controllers (Source, Kustomize, Helm)

**When to use**: When you want pure automation without UI overhead, or for edge/IoT deployments.

### How They Work Together

You **combine** Kustomize with Argo CD or Flux:

1. **Write** manifests using Kustomize (base + overlays)
2. **Push** to Git repository
3. **Argo CD or Flux** detects the change
4. **Argo CD or Flux** runs `kustomize build` internally
5. **Argo CD or Flux** applies YAML to cluster

**You don't choose between them - you use Kustomize WITH Argo CD or Flux!**

---

## What You'll Learn

### GitOps Fundamentals
- GitOps principles and workflows
- Configuration vs. deployment tools
- Declarative infrastructure management
- Automated deployment pipelines

### Kustomize (Configuration Management)
- Base and overlay patterns
- Environment-specific configurations
- Resource patching and transformations
- Multi-environment management

### Argo CD (Visual GitOps)
- Argo CD installation and setup
- Application definitions
- Visual dashboard usage
- Sync policies and automation

### Flux (CLI GitOps)
- Flux installation and setup
- GitRepository and Kustomization resources
- CLI-based management
- Modular controller architecture

### Best Practices
- GitOps workflow design
- Environment separation
- Security and access control
- Monitoring and observability

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Git Repository                            │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Kustomize Base + Overlays                          │    │
│  │  ├── base/                                          │    │
│  │  ├── overlays/staging/                              │    │
│  │  └── overlays/production/                           │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                   │
│                          │ Push                              │
│                          ▼                                   │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Watch
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              Kubernetes Cluster                              │
│                                                               │
│  ┌──────────────┐      ┌──────────────┐                     │
│  │   Argo CD    │  OR  │    Flux      │                     │
│  │  (Visual UI) │      │  (CLI-based) │                     │
│  └──────┬───────┘      └──────┬───────┘                     │
│         │                      │                              │
│         └──────────┬───────────┘                              │
│                    │                                          │
│                    ▼                                          │
│         ┌──────────────────────┐                              │
│         │  Application Pods    │                              │
│         │  (Deployed via       │                              │
│         │   GitOps)            │                              │
│         └──────────────────────┘                              │
└─────────────────────────────────────────────────────────────┘
```

### GitOps Workflow

1. **Developer** commits changes to Git
2. **Kustomize** generates environment-specific YAML
3. **Argo CD/Flux** detects Git changes
4. **Argo CD/Flux** applies changes to cluster
5. **Application** is automatically updated

---

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **kubectl** | 1.28+ | Kubernetes cluster management |
| **kustomize** | 4.5+ | Configuration management |
| **Helm** | 3.10+ | Package management |
| **Git** | 2.30+ | Version control |

### AWS Requirements

- **EKS Cluster** from Lab 02 (or existing Kubernetes cluster)
- **kubectl** configured to access the cluster
- **Git repository** (GitHub, GitLab, etc.)

### Knowledge Prerequisites

- Basic Kubernetes concepts
- Understanding of Lab 02 (Kubernetes Platform)
- Basic Git knowledge

### Lab Dependencies

**Required**: Complete [Lab 02](../02-kubernetes-platform/) first to have an EKS cluster.

---

## Quick Start

For experienced users who want to deploy immediately:

```bash
# 1. Navigate to lab directory
cd labs/06-gitops-workflows

# 2. Choose your GitOps tool (Argo CD or Flux)
# For Argo CD (visual):
make install-argocd

# For Flux (CLI):
make install-flux

# 3. Set up Kustomize base and overlays
make setup-kustomize

# 4. Verify installation
make status
```

**Setup time**: ~20-30 minutes  
**Estimated cost**: $1-3 to complete (vs $20-30/month if kept running)

---

## Detailed Setup

### Step 1: Verify Cluster Access

```bash
# Check kubectl is configured
kubectl cluster-info
kubectl get nodes
```

### Step 2: Set Up Kustomize

```bash
# Create base and overlay structure
make setup-kustomize

# Build staging configuration
kubectl kustomize kustomize/overlays/staging

# Build production configuration
kubectl kustomize kustomize/overlays/production
```

### Step 3: Choose Your GitOps Tool

**Option A: Argo CD (Visual Dashboard)**

```bash
make install-argocd
# Access UI at: https://localhost:8080 (port-forward)
```

**Option B: Flux (CLI-Focused)**

```bash
make install-flux
# Manage via flux CLI
```

### Step 4: Configure GitOps

```bash
# For Argo CD
make configure-argocd

# For Flux
make configure-flux
```

---

## Project Structure

```
labs/06-gitops-workflows/
├── README.md                    # This file
├── Makefile                     # Automation commands
├── kustomize/                   # Kustomize configurations
│   ├── base/                    # Base manifests
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── configmap.yaml
│   └── overlays/                # Environment overlays
│       ├── staging/
│       │   ├── kustomization.yaml
│       │   └── patches/
│       └── production/
│           ├── kustomization.yaml
│           └── patches/
├── argocd/                      # Argo CD configuration
│   ├── README.md
│   ├── application.yaml        # App definition
│   └── values.yaml             # Helm values
├── flux/                        # Flux configuration
│   ├── README.md
│   ├── gitrepository.yaml      # Git source
│   └── kustomization.yaml      # Kustomize deployment
├── TOOL-COMPARISON.md          # Detailed comparison
└── scripts/                     # Automation scripts
    ├── validate.sh
    └── test-gitops.sh
```

---

## Kustomize

Kustomize helps you manage Kubernetes YAML files across multiple environments.

### Base Configuration

The `base/` directory contains common configurations:

```yaml
# kustomize/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml

commonLabels:
  app: sample-app
  managed-by: kustomize
```

### Environment Overlays

The `overlays/` directory contains environment-specific patches:

```yaml
# kustomize/overlays/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

replicas:
  - name: sample-app
    count: 2

patches:
  - path: patches/resource-limits.yaml

namespace: staging
```

See [kustomize/README.md](kustomize/README.md) for detailed usage.

---

## Argo CD

Argo CD provides a visual GitOps platform with a web dashboard.

### Installation

```bash
make install-argocd
```

### Application Definition

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/your-repo
    targetRevision: main
    path: kustomize/overlays/staging
    kustomize: {}
  destination:
    server: https://kubernetes.default.svc
    namespace: staging
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Accessing the UI

```bash
# Port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

See [argocd/README.md](argocd/README.md) for detailed usage.

---

## Flux

Flux provides a lightweight, CLI-focused GitOps solution.

### Installation

```bash
make install-flux
```

### GitRepository Resource

```yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: sample-app
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/your-org/your-repo
  ref:
    branch: main
```

### Kustomization Resource

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: sample-app
  namespace: flux-system
spec:
  interval: 5m
  path: ./kustomize/overlays/staging
  prune: true
  sourceRef:
    kind: GitRepository
    name: sample-app
  targetNamespace: staging
```

See [flux/README.md](flux/README.md) for detailed usage.

---

## Tool Comparison

| Feature | Kustomize | Argo CD | Flux |
|---------|-----------|---------|------|
| **Role** | Configuration | Deployment | Deployment |
| **Interface** | CLI | Visual UI | CLI |
| **Architecture** | Tool | Centralized | Modular |
| **Best For** | Organizing YAML | Visual teams | Platform engineers |
| **Multi-Tenancy** | N/A | Built-in SSO | Kubernetes RBAC |
| **Use Case** | Write manifests | Deploy with UI | Deploy headless |

**Remember**: Use Kustomize WITH Argo CD or Flux, not instead of them!

See [TOOL-COMPARISON.md](TOOL-COMPARISON.md) for detailed comparison.

---

## Integration Examples

### Complete GitOps Workflow

1. **Write** manifests with Kustomize
2. **Commit** to Git repository
3. **Argo CD/Flux** detects changes
4. **Automatic** deployment to cluster

### Multi-Environment Deployment

```bash
# Staging deployment
kubectl kustomize kustomize/overlays/staging | kubectl apply -f -

# Production deployment
kubectl kustomize kustomize/overlays/production | kubectl apply -f -
```

---

## Troubleshooting

### Kustomize Build Fails

```bash
# Validate kustomization.yaml
kubectl kustomize kustomize/base --dry-run=client

# Check for syntax errors
kubectl kustomize kustomize/overlays/staging
```

### Argo CD Not Syncing

```bash
# Check Argo CD pods
kubectl get pods -n argocd

# Check application status
kubectl get application -n argocd

# View Argo CD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

### Flux Not Deploying

```bash
# Check Flux controllers
kubectl get pods -n flux-system

# Check GitRepository status
flux get sources git

# Check Kustomization status
flux get kustomizations

# View Flux logs
kubectl logs -n flux-system -l app=source-controller
```

---

## Cleanup

### Remove All GitOps Tools

```bash
# Uninstall everything
make uninstall-all

# Or manually
make uninstall-argocd
make uninstall-flux
```

---

## Learning Objectives

### Beginner Level ✅
After completing this lab, you should understand:
- What GitOps means
- Difference between configuration and deployment tools
- Basic Kustomize usage
- How Argo CD/Flux work

### Intermediate Level ✅
You should be able to:
- Create Kustomize base and overlays
- Set up Argo CD applications
- Configure Flux GitRepositories
- Manage multi-environment deployments

### Advanced Level ✅
You should master:
- Complete GitOps workflows
- Advanced Kustomize patching
- Argo CD sync policies
- Flux automation patterns

---

## Best Practices Demonstrated

### GitOps
- ✅ **Declarative**: Everything defined in Git
- ✅ **Automated**: No manual kubectl apply
- ✅ **Auditable**: All changes tracked in Git
- ✅ **Reproducible**: Same Git state = same cluster state

### Configuration Management
- ✅ **Base + Overlays**: DRY principle
- ✅ **Environment Separation**: Clear staging/prod split
- ✅ **Version Control**: All configs in Git

### Deployment
- ✅ **Automated Sync**: Changes auto-deployed
- ✅ **Self-Healing**: Cluster matches Git state
- ✅ **Rollback**: Git revert = cluster rollback

---

## Cost Considerations

### Estimated Costs

**Monthly Cost** (if running continuously): ~$20-30
- Argo CD: $10-15/month
- Flux: $5-10/month
- Kustomize: No additional cost (CLI tool)

**Cost to Complete** (run for 1-2 hours): ~$1-3
- Component deployment: Minimal
- GitOps operations: Negligible
- Monitoring overhead: Included in cluster costs

### Cost Optimization

- Use Flux for lower overhead (if UI not needed)
- Argo CD and Flux are lightweight
- Kustomize has no additional cost
- Destroy test resources immediately

---

## Next Steps

### Immediate Next Actions
1. **Set up Kustomize** base and overlays
2. **Choose GitOps tool** (Argo CD or Flux)
3. **Configure Git repository** connection
4. **Test automated deployment**

### Continue Your Learning Journey

#### Next Recommended Lab
- **[Lab 07 - Serverless Operations](../07-serverless-operations/README.md)** - Serverless applications

#### Related Labs
- **[Lab 02: Kubernetes Platform](../02-kubernetes-platform/README.md)** - Deploy to this cluster
- **[Lab 03: CI/CD Pipelines](../03-cicd-pipelines/README.md)** - Integrate with GitOps
- **[Lab 05: Security Automation](../05-security-automation/README.md)** - Secure GitOps deployments

---

## Additional Resources

### Documentation
- [Kustomize Documentation](https://kustomize.io/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Flux Documentation](https://fluxcd.io/docs/)

### Learning Resources
- [GitOps Principles](https://www.gitops.tech/)
- [Kustomize Tutorial](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)

---

**🎉 Congratulations!** You've implemented a complete GitOps workflow using Kustomize for configuration management and Argo CD/Flux for automated deployments. Your platform now follows industry-standard GitOps practices!

**Ready for the next challenge?** Continue to [Lab 07 - Serverless Operations](../07-serverless-operations/) to build serverless applications!

