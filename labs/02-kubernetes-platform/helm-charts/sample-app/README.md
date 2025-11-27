# Sample App Helm Chart

This is a sample Helm chart demonstrating Helm chart structure and best practices. It can be used as a template for creating your own Helm charts.

## Chart Structure

```
sample-app/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration values
├── README.md           # This file
└── templates/          # Kubernetes manifest templates
    ├── _helpers.tpl    # Template helpers
    ├── deployment.yaml # Deployment template
    ├── service.yaml    # Service template
    ├── ingress.yaml    # Ingress template (optional)
    ├── serviceaccount.yaml
    ├── configmap.yaml  # ConfigMap template (optional)
    ├── secret.yaml     # Secret template (optional)
    └── hpa.yaml        # HorizontalPodAutoscaler (optional)
```

## Installation

### Basic Installation

```bash
# Install with default values
helm install sample-app ./helm-charts/sample-app

# Install with custom values
helm install sample-app ./helm-charts/sample-app -f my-values.yaml

# Install with inline values
helm install sample-app ./helm-charts/sample-app \
  --set replicaCount=3 \
  --set image.tag=1.26
```

### Installation with Ingress

```bash
helm install sample-app ./helm-charts/sample-app \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=sample-app.example.com
```

## Configuration

Key configuration options in `values.yaml`:

- **replicaCount**: Number of replicas (default: 2)
- **image**: Container image configuration
- **service**: Service type and ports
- **ingress**: Ingress configuration (disabled by default)
- **resources**: CPU and memory limits/requests
- **autoscaling**: Horizontal Pod Autoscaler configuration
- **env**: Environment variables
- **configMap**: ConfigMap data
- **secret**: Secret data (base64 encoded)

## Examples

### Example 1: Basic Deployment

```bash
helm install sample-app ./helm-charts/sample-app
```

### Example 2: Production Configuration

```bash
helm install sample-app ./helm-charts/sample-app \
  --set replicaCount=5 \
  --set resources.limits.cpu=500m \
  --set resources.limits.memory=512Mi \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=app.example.com
```

### Example 3: With Custom Values File

Create `my-values.yaml`:

```yaml
replicaCount: 3
image:
  tag: "1.26"
ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
resources:
  limits:
    cpu: 500m
    memory: 512Mi
```

Install:

```bash
helm install sample-app ./helm-charts/sample-app -f my-values.yaml
```

### Example 4: With Environment Variables

```bash
helm install sample-app ./helm-charts/sample-app \
  --set env[0].name=ENV_VAR \
  --set env[0].value=value
```

### Example 5: With Autoscaling

```bash
helm install sample-app ./helm-charts/sample-app \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=2 \
  --set autoscaling.maxReplicas=10 \
  --set autoscaling.targetCPUUtilizationPercentage=80
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade sample-app ./helm-charts/sample-app -f new-values.yaml

# Upgrade with inline values
helm upgrade sample-app ./helm-charts/sample-app \
  --set replicaCount=5
```

## Uninstalling

```bash
helm uninstall sample-app
```

## Validation

Before deploying, validate your Helm chart:

```bash
# Lint the chart (checks for errors and best practices)
helm lint ./helm-charts/sample-app

# Or use the Makefile
make lint-helm

# Validate template rendering (ensures templates are valid)
helm template sample-app ./helm-charts/sample-app --dry-run

# Or use the Makefile
make validate-helm
```

## Verifying

```bash
# Check release status
helm status sample-app

# List all releases
helm list

# Get deployed resources
kubectl get all -l app.kubernetes.io/instance=sample-app
```

## Customization

To customize this chart for your application:

1. **Update Chart.yaml**: Change name, description, version
2. **Modify values.yaml**: Adjust default values for your app
3. **Update templates**: Customize Kubernetes manifests as needed
4. **Add helpers**: Extend `_helpers.tpl` with custom template functions

## Best Practices Demonstrated

- ✅ **Template Helpers**: Reusable template functions in `_helpers.tpl`
- ✅ **Values Structure**: Organized, documented values
- ✅ **Conditional Resources**: Optional resources (ingress, HPA, etc.)
- ✅ **Labels**: Consistent labeling for resource management
- ✅ **Security**: Security contexts and service accounts
- ✅ **Health Checks**: Liveness and readiness probes
- ✅ **Resource Limits**: CPU and memory constraints
- ✅ **Flexibility**: Support for multiple deployment scenarios

## Learning Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

