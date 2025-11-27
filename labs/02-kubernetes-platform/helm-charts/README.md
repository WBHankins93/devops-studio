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

### Sample App Chart

A complete example Helm chart is provided in `sample-app/` directory. This demonstrates:

- Chart structure and organization
- Template helpers and functions
- Values customization
- Optional resources (Ingress, HPA, ConfigMap, Secret)
- Best practices for Helm chart development

**Install the sample chart**:
```bash
# Using Makefile
make deploy-helm-chart

# Or manually
helm install sample-app ./helm-charts/sample-app \
  --namespace devops-studio \
  --create-namespace
```

See `sample-app/README.md` for detailed usage and examples.

### Chart Structure

```
helm-charts/
├── sample-app/          # Example Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── README.md
│   └── templates/
│       ├── _helpers.tpl
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── serviceaccount.yaml
│       ├── configmap.yaml
│       ├── secret.yaml
│       └── hpa.yaml
└── your-app/            # Your custom chart
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

