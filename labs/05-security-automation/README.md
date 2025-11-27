# Lab 05 - Security Automation
*Implementing DevSecOps with Trivy, OPA, Falco, and RBAC*

> **Navigation**: [DevOps Studio](../../README.md) > [Labs](../README.md) > Lab 05  
> **Previous Lab**: [Lab 04 - Observability Stack](../04-observability-stack/README.md)  
> **Next Lab**: [Lab 06 - GitOps Workflows](../06-gitops-workflows/README.md)

[![Trivy](https://img.shields.io/badge/Trivy-1904DA?logo=aquasecurity)](https://aquasecurity.github.io/trivy/)
[![OPA](https://img.shields.io/badge/OPA-7A858D?logo=openpolicyagent)](https://www.openpolicyagent.org/)
[![Falco](https://img.shields.io/badge/Falco-00BCE4?logo=falco)](https://falco.org/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes)](https://kubernetes.io)

> **Objective**: Implement comprehensive security automation covering vulnerability scanning (Trivy), policy enforcement (OPA), runtime security (Falco), and access control (RBAC). Learn DevSecOps practices to secure your Kubernetes platform and applications.

---

## 📑 Table of Contents

- [Overview](#overview)
- [What You'll Learn](#what-youll-learn)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Project Structure](#project-structure)
- [Security Tools](#security-tools)
- [Integration](#integration)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Learning Objectives](#learning-objectives)
- [Best Practices Demonstrated](#best-practices-demonstrated)
- [Cost Considerations](#cost-considerations)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

---

## Overview

This lab implements a complete DevSecOps security stack that automates security at every stage of the software lifecycle: build, deploy, and runtime.

### What Gets Built

- **Trivy** - Advanced vulnerability scanning (images, filesystems, infrastructure)
- **OPA Gatekeeper** - Policy enforcement for Kubernetes resources
- **Falco** - Runtime security monitoring and threat detection
- **RBAC** - Role-based access control configurations
- **Security Policies** - Pre-built policies for common security requirements
- **Automated Scanning** - CI/CD integration for continuous security

### Key Features

- ✅ **Shift-Left Security**: Catch issues early in development
- ✅ **Policy as Code**: Version-controlled security policies
- ✅ **Runtime Protection**: Detect threats in running containers
- ✅ **Access Control**: Least privilege access management
- ✅ **Automated Enforcement**: Policies enforced automatically
- ✅ **Production Ready**: Enterprise-grade security configurations

---

## What You'll Learn

### DevSecOps Fundamentals
- Shift-left security practices
- Security automation principles
- Policy as code
- Continuous security scanning

### Trivy (Vulnerability Scanning)
- Container image scanning
- Filesystem scanning
- Infrastructure as Code scanning
- Kubernetes cluster scanning
- CI/CD integration

### OPA (Policy Enforcement)
- Open Policy Agent basics
- Rego policy language
- OPA Gatekeeper for Kubernetes
- Policy templates and constraints
- Admission control

### Falco (Runtime Security)
- Runtime threat detection
- System call monitoring
- Custom rules creation
- Alerting and notifications
- Integration with SIEM

### RBAC (Access Control)
- Kubernetes RBAC model
- Role and ClusterRole creation
- Service account security
- Least privilege principles
- Access auditing

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Development & CI/CD                        │
│                                                               │
│  ┌──────────────┐      ┌──────────────┐                     │
│  │   Trivy       │      │   OPA         │                     │
│  │   (Scanning)  │      │   (Policies)  │                     │
│  └──────┬───────┘      └──────┬───────┘                     │
│         │                      │                              │
│         └──────────┬───────────┘                              │
│                    │                                          │
│                    ▼                                          │
│         ┌──────────────────────┐                              │
│         │  Kubernetes Cluster   │                              │
│         │  (Deployment)         │                              │
│         └──────────┬────────────┘                              │
│                    │                                          │
│        ┌───────────┼───────────┐                               │
│        │           │           │                               │
│        ▼           ▼           ▼                               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                         │
│  │  RBAC   │ │  Falco   │ │  OPA    │                         │
│  │ (Access)│ │(Runtime) │ │(Policy) │                         │
│  └─────────┘ └─────────┘ └─────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

### Security Layers

| Layer | Tool | Protection |
|-------|------|------------|
| **Build** | Trivy | Vulnerable dependencies, misconfigurations |
| **Deploy** | OPA | Policy violations, security requirements |
| **Runtime** | Falco | Suspicious behavior, attacks |
| **Access** | RBAC | Unauthorized actions, privilege abuse |

---

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **kubectl** | 1.28+ | Kubernetes cluster management |
| **Helm** | 3.10+ | Package management |
| **Trivy** | 0.45+ | Vulnerability scanning |

### AWS Requirements

- **EKS Cluster** from Lab 02 (or existing Kubernetes cluster)
- **kubectl** configured to access the cluster

### Knowledge Prerequisites

- Basic Kubernetes concepts
- Understanding of Lab 02 (Kubernetes Platform)
- Basic security concepts

### Lab Dependencies

**Required**: Complete [Lab 02](../02-kubernetes-platform/) first to have an EKS cluster.

---

## Quick Start

For experienced users who want to deploy immediately:

```bash
# 1. Navigate to lab directory
cd labs/05-security-automation

# 2. Install all security tools
make install-all

# 3. Verify installation
make status

# 4. Test security tools
make test
```

**Setup time**: ~15-20 minutes  
**Estimated cost**: $1-3 to complete (vs $30-50/month if kept running)

---

## Detailed Setup

### Step 1: Verify Cluster Access

```bash
# Check kubectl is configured
kubectl cluster-info
kubectl get nodes
```

### Step 2: Install Security Tools

You can install components individually or all at once:

```bash
# Install all at once (recommended)
make install-all

# Or install individually
make install-trivy
make install-opa
make install-falco
make setup-rbac
```

### Step 3: Verify Installation

```bash
# Check status
make status

# Run validation
make validate
```

---

## Project Structure

```
labs/05-security-automation/
├── README.md                    # This file
├── Makefile                     # Automation commands
├── trivy/                       # Trivy configurations
│   ├── README.md               # Trivy guide
│   ├── config.yaml             # Trivy configuration
│   └── policies/               # Custom policies
├── opa/                         # OPA Gatekeeper
│   ├── README.md               # OPA guide
│   ├── policies/               # Rego policies
│   └── constraints/            # Kubernetes constraints
├── falco/                       # Falco runtime security
│   ├── README.md               # Falco guide
│   ├── rules/                  # Custom Falco rules
│   └── config.yaml             # Falco configuration
├── rbac/                        # RBAC configurations
│   ├── README.md               # RBAC guide
│   ├── roles/                  # Role definitions
│   └── bindings/               # Role bindings
└── scripts/                     # Automation scripts
    ├── validate.sh             # Validation script
    └── test-security.sh        # Security testing
```

---

## Security Tools

### Trivy (Vulnerability Scanning)

**What it does**: Scans container images, filesystems, and infrastructure for vulnerabilities.

**Key Features**:
- Container image scanning
- Filesystem scanning
- IaC scanning (Terraform, CloudFormation)
- Kubernetes cluster scanning
- CI/CD integration

See [trivy/README.md](trivy/README.md) for detailed usage.

### OPA Gatekeeper (Policy Enforcement)

**What it does**: Enforces security policies on Kubernetes resources before they're created.

**Key Features**:
- Admission control
- Policy as code (Rego)
- Pre-built policy templates
- Custom policy creation

See [opa/README.md](opa/README.md) for detailed usage.

### Falco (Runtime Security)

**What it does**: Monitors running containers and detects suspicious behavior in real-time.

**Key Features**:
- System call monitoring
- Threat detection
- Custom rules
- Alerting integration

See [falco/README.md](falco/README.md) for detailed usage.

### RBAC (Access Control)

**What it does**: Controls who can perform what actions in Kubernetes.

**Key Features**:
- Role-based permissions
- Service account security
- Least privilege access
- Audit logging

See [rbac/README.md](rbac/README.md) for detailed usage.

---

## Integration

### CI/CD Integration

Integrate security tools into your CI/CD pipeline:

```yaml
# GitHub Actions example
- name: Run Trivy scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.IMAGE }}
    format: 'sarif'
    output: 'trivy-results.sarif'
```

### Complete Security Flow

1. **Build**: Trivy scans images
2. **Deploy**: OPA validates policies
3. **Runtime**: Falco monitors behavior
4. **Access**: RBAC controls permissions

---

## Usage Examples

### Scan Container Image

```bash
# Scan image
trivy image nginx:latest

# Scan with specific severity
trivy image --severity HIGH,CRITICAL nginx:latest

# Scan Kubernetes cluster
trivy k8s cluster
```

### Enforce Policy

```bash
# Apply OPA constraint
kubectl apply -f opa/constraints/require-resource-limits.yaml

# Test policy violation
kubectl apply -f test-pod-without-limits.yaml
# Should be rejected by OPA
```

### Monitor Runtime

```bash
# View Falco events
kubectl logs -n falco -l app=falco

# Test Falco detection
# Execute shell in container (should trigger alert)
kubectl exec -it <pod> -- /bin/sh
```

---

## Troubleshooting

### Trivy Not Finding Vulnerabilities

```bash
# Update vulnerability database
trivy image --download-db-only

# Check Trivy version
trivy --version
```

### OPA Policies Not Enforcing

```bash
# Check Gatekeeper is running
kubectl get pods -n gatekeeper-system

# Check constraint status
kubectl get constrainttemplate
kubectl get constraint
```

### Falco Not Detecting Events

```bash
# Check Falco pods
kubectl get pods -n falco

# Check Falco logs
kubectl logs -n falco -l app=falco

# Verify rules are loaded
kubectl exec -n falco <falco-pod> -- falco --list-rules
```

---

## Cleanup

### Remove All Security Tools

```bash
# Uninstall everything
make uninstall-all

# Or manually
make uninstall-trivy
make uninstall-opa
make uninstall-falco
```

---

## Learning Objectives

### Beginner Level ✅
After completing this lab, you should understand:
- What DevSecOps means
- Basic security scanning concepts
- Policy enforcement basics
- Access control fundamentals

### Intermediate Level ✅
You should be able to:
- Configure vulnerability scanners
- Write basic OPA policies
- Create Falco rules
- Design RBAC roles

### Advanced Level ✅
You should master:
- Complete security automation
- Custom policy development
- Runtime threat detection
- Security architecture design

---

## Best Practices Demonstrated

### Security
- ✅ **Shift-Left**: Security early in development
- ✅ **Policy as Code**: Version-controlled policies
- ✅ **Automated Enforcement**: No manual checks needed
- ✅ **Defense in Depth**: Multiple security layers
- ✅ **Least Privilege**: Minimal required access

### Automation
- ✅ **CI/CD Integration**: Automated scanning
- ✅ **Admission Control**: Automatic policy enforcement
- ✅ **Real-time Monitoring**: Continuous threat detection
- ✅ **Audit Trail**: Complete security logging

---

## Cost Considerations

### Estimated Costs

**Monthly Cost** (if running continuously): ~$30-50
- Falco: $10-15/month
- OPA Gatekeeper: $5-10/month
- Trivy: Minimal (mostly CI/CD usage)
- RBAC: No additional cost

**Cost to Complete** (run for 1-2 hours): ~$1-3
- Component deployment: Minimal
- Scanning operations: Negligible
- Monitoring overhead: Included in cluster costs

### Cost Optimization

- Use Trivy in CI/CD (free tier available)
- Falco and OPA are lightweight
- RBAC has no additional cost
- Destroy test resources immediately

---

## Next Steps

### Immediate Next Actions
1. **Install security tools** and verify they're working
2. **Test policies** by trying to violate them
3. **Monitor Falco** for runtime events
4. **Review RBAC** configurations

### Continue Your Learning Journey

#### Next Recommended Lab
- **[Lab 06 - GitOps Workflows](../06-gitops-workflows/README.md)** - Secure GitOps deployments

#### Related Labs
- **[Lab 02: Kubernetes Platform](../02-kubernetes-platform/README.md)** - Secure this cluster
- **[Lab 03: CI/CD Pipelines](../03-cicd-pipelines/README.md)** - Integrate security scanning
- **[Lab 04: Observability Stack](../04-observability-stack/README.md)** - Monitor security events

---

## Additional Resources

### Documentation
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [OPA Documentation](https://www.openpolicyagent.org/docs/)
- [Falco Documentation](https://falco.org/docs/)
- [Kubernetes RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)

### Learning Resources
- [DevSecOps Best Practices](https://www.redhat.com/en/topics/devops/what-is-devsecops)
- [Policy as Code Guide](https://www.openpolicyagent.org/docs/latest/policy-language/)

---

**🎉 Congratulations!** You've implemented a complete security automation stack covering scanning, policy enforcement, runtime protection, and access control. Your platform is now secured with industry-standard DevSecOps practices!

**Ready for the next challenge?** Continue to [Lab 06 - GitOps Workflows](../06-gitops-workflows/) to deploy securely with GitOps!

