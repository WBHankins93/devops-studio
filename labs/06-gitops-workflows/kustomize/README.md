# Kustomize - Configuration Management

Kustomize is a template-free configuration management tool for Kubernetes. It helps you organize and customize Kubernetes YAML files without duplicating code.

## Overview

Kustomize provides:
- **Base Configurations** - Common manifests shared across environments
- **Overlays** - Environment-specific patches (staging, production)
- **Resource Patching** - Modify resources without copying entire files
- **Template-Free** - No new programming language to learn

## Key Concepts

### Base

The `base/` directory contains the common configuration that all environments share.

### Overlays

The `overlays/` directory contains environment-specific patches that modify the base.

### How It Works

1. Define base configuration
2. Create overlays for each environment
3. Kustomize merges base + overlay
4. Output final YAML for deployment

## Usage

### Build Configuration

```bash
# Build staging configuration
kubectl kustomize kustomize/overlays/staging

# Build production configuration
kubectl kustomize kustomize/overlays/production

# Apply directly
kubectl apply -k kustomize/overlays/staging
```

### Common Operations

```bash
# Preview changes
kubectl kustomize kustomize/overlays/staging

# Validate
kubectl kustomize kustomize/overlays/staging --dry-run=client

# Apply
kubectl apply -k kustomize/overlays/staging
```

## Base Structure

```
base/
├── kustomization.yaml    # Base configuration
├── deployment.yaml      # Common deployment
├── service.yaml         # Common service
└── configmap.yaml       # Common config
```

## Overlay Structure

```
overlays/
├── staging/
│   ├── kustomization.yaml    # References base + patches
│   └── patches/
│       └── resource-limits.yaml
└── production/
    ├── kustomization.yaml
    └── patches/
        └── resource-limits.yaml
```

## Examples

### Base Kustomization

```yaml
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

### Staging Overlay

```yaml
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

### Production Overlay

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

replicas:
  - name: sample-app
    count: 5

patches:
  - path: patches/resource-limits.yaml

namespace: production
```

## Best Practices

1. **Keep base minimal** - Only common configurations
2. **Use overlays for differences** - Environment-specific changes
3. **Version control everything** - Base and overlays in Git
4. **Test builds** - Always preview before applying

## Additional Resources

- [Kustomize Documentation](https://kustomize.io/)
- [Kustomize Tutorial](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)

