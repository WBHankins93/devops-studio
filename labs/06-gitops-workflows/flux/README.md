# Flux - CLI-Focused GitOps

Flux is a lightweight, modular GitOps tool designed for platform engineers who prefer CLI-based automation.

## Overview

Flux provides:
- **CLI-First** - Manage via command line
- **Modular Architecture** - Small, focused controllers
- **Lightweight** - Minimal resource overhead
- **Native Kubernetes** - Feels like native K8s resources
- **Headless** - No UI, pure automation

## Installation

### Using Flux CLI

```bash
# Install Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Bootstrap Flux
flux bootstrap github \
  --owner=your-org \
  --repository=your-repo \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```

### Using Helm

```bash
helm repo add fluxcd https://fluxcd-community.github.io/helm-charts
helm repo update

helm install flux fluxcd/flux2 \
  --namespace flux-system \
  --create-namespace
```

## GitRepository Resource

Defines the Git source to watch:

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
  secretRef:
    name: git-credentials
```

## Kustomization Resource

Defines what to deploy from the Git repository:

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
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: sample-app
      namespace: staging
```

## Usage

### Create Resources

```bash
kubectl apply -f flux/gitrepository.yaml
kubectl apply -f flux/kustomization.yaml
```

### Check Status

```bash
# Check GitRepository
flux get sources git

# Check Kustomization
flux get kustomizations

# Check all Flux resources
flux get all
```

### Reconcile

```bash
# Trigger reconciliation
flux reconcile source git sample-app
flux reconcile kustomization sample-app
```

### View Logs

```bash
# Source controller logs
kubectl logs -n flux-system -l app=source-controller

# Kustomize controller logs
kubectl logs -n flux-system -l app=kustomize-controller
```

## Best Practices

1. **Use short intervals** for staging (1-5 minutes)
2. **Use longer intervals** for production (15-30 minutes)
3. **Enable pruning** to remove deleted resources
4. **Use health checks** to verify deployments

## Additional Resources

- [Flux Documentation](https://fluxcd.io/docs/)
- [Flux CLI Reference](https://fluxcd.io/docs/cmd/)

