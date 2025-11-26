# Helm Charts

This directory contains Helm chart configurations and instructions for common Kubernetes tools.

## Available Charts

### NGINX Ingress Controller

The NGINX Ingress Controller is installed via the Makefile using the official Helm chart.

**Installation**:
```bash
make install-helm-charts
```

**Manual Installation**:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer
```

**Verify**:
```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### Metrics Server

Metrics Server is installed via the Makefile for resource metrics.

**Installation**:
```bash
make install-helm-charts
```

**Manual Installation**:
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args="{--kubelet-insecure-tls}"
```

**Verify**:
```bash
kubectl top nodes
kubectl top pods --all-namespaces
```

## Custom Charts

You can add custom Helm charts to this directory for your applications.

### Chart Structure

```
helm-charts/
└── your-app/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml
        ├── service.yaml
        └── ingress.yaml
```

## Usage

After installing charts, you can:

1. **List installed releases**:
   ```bash
   helm list --all-namespaces
   ```

2. **Upgrade a release**:
   ```bash
   helm upgrade ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
   ```

3. **Uninstall a release**:
   ```bash
   helm uninstall ingress-nginx -n ingress-nginx
   ```

## Additional Charts

Consider installing these charts for a complete platform:

- **cert-manager**: TLS certificate management
- **prometheus**: Metrics collection
- **grafana**: Metrics visualization
- **argo-cd**: GitOps continuous delivery

See Lab 04 (Observability Stack) and Lab 06 (GitOps Workflows) for more details.

