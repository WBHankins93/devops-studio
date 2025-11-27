# Automation Layer

Automation scripts and tools that execute platform operations.

## Overview

The automation layer handles:
- Terraform execution
- CI/CD pipeline generation
- Resource validation
- Approval workflows

## Components

### Terraform Runner

Executes Terraform plans and applies for service provisioning.

**Features**:
- Workspace isolation
- State management
- Plan review
- Error handling
- Rollback support

See [terraform-runner/README.md](terraform-runner/README.md) for details.

### CI/CD Generator

Generates CI/CD pipeline configurations.

**Features**:
- Template-based generation
- Multi-environment support
- GitHub Actions integration
- Customizable workflows

See [ci-cd-generator/README.md](ci-cd-generator/README.md) for details.

## Workflow

```
API Request → Validation → Terraform Runner → AWS → Status Update
```

## Security

- IAM role assumption
- Least privilege permissions
- Audit logging
- State encryption

