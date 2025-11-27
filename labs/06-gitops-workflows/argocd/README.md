# Argo CD - Visual GitOps Platform

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes with a beautiful web UI.

## Overview

Argo CD provides:
- **Visual Dashboard** - Web UI for monitoring deployments
- **Automated Sync** - Automatically deploy from Git
- **Multi-Cluster Support** - Manage multiple clusters
- **SSO Integration** - Built-in user management
- **Application Health** - Visual status of applications

## Installation

### Using Helm

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --values values.yaml
```

### Access the UI

```bash
# Port-forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access UI at: https://localhost:8080
# Username: admin
```

## Application Definition

### Basic Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: argocd
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

### Application with Manual Sync

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/your-repo
    targetRevision: main
    path: kustomize/overlays/production
    kustomize: {}
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
    automated:
      prune: false
      selfHeal: false
```

## Usage

### Create Application

```bash
kubectl apply -f argocd/application.yaml
```

### View Applications

```bash
# CLI
kubectl get applications -n argocd

# UI
# Open https://localhost:8080 and login
```

### Sync Application

```bash
# Manual sync via CLI
argocd app sync sample-app

# Or use UI to click "Sync" button
```

### View Application Status

```bash
argocd app get sample-app
```

## Best Practices

1. **Use Automated Sync** for staging environments
2. **Manual Sync** for production (with approval)
3. **Self-Healing** enabled for automatic drift correction
4. **Prune Resources** to remove deleted resources

## Additional Resources

- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Argo CD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)

