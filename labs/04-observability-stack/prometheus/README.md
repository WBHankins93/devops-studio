# Prometheus - Metrics Collection

Prometheus is a monitoring and alerting toolkit that collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts.

## Overview

Prometheus provides:
- **Time-series database** - Stores metrics over time
- **PromQL** - Powerful query language
- **Service discovery** - Automatically discovers targets
- **Alerting** - AlertManager integration
- **Exporters** - Collect metrics from various systems

## Architecture

```
┌─────────────────────────────────────────────────┐
│         Application Services                     │
│  (Pods, Services, Infrastructure)                │
└──────────────────┬──────────────────────────────┘
                    │
                    ▼
         ┌──────────────────┐
         │  Prometheus      │
         │  (Scraper)        │
         └────────┬──────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  Prometheus      │
         │  (Storage)        │
         └────────┬──────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  AlertManager     │
         │  (Alerts)         │
         └──────────────────┘
```

## Installation

### Using Helm (Recommended)

```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack (includes Prometheus, Grafana, AlertManager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace observability \
  --create-namespace \
  --values values.yaml
```

### Configuration

Edit `values.yaml` to customize:

```yaml
prometheus:
  prometheusSpec:
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: gp3
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
    resources:
      requests:
        memory: 2Gi
        cpu: 1
      limits:
        memory: 4Gi
        cpu: 2
```

## Usage

### Access Prometheus UI

```bash
# Port forward to access UI
kubectl port-forward -n observability svc/prometheus-kube-prometheus-prometheus 9090:9090

# Open in browser
open http://localhost:9090
```

### Query Metrics

#### PromQL Examples

```promql
# CPU usage rate
rate(container_cpu_usage_seconds_total[5m])

# Memory usage
container_memory_usage_bytes

# HTTP request rate
rate(http_requests_total[5m])

# Pod count by namespace
count(kube_pod_info) by (namespace)

# Node CPU utilization
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Available memory percentage
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```

### Service Discovery

Prometheus automatically discovers:
- Kubernetes pods
- Kubernetes services
- Kubernetes nodes
- Kubernetes endpoints

### Alerting Rules

Create alert rules in `alert-rules.yaml`:

```yaml
groups:
  - name: kubernetes
    rules:
      - alert: HighCPUUsage
        expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for 5 minutes"

      - alert: HighMemoryUsage
        expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 90%"
```

## Integration

### Grafana Integration

Prometheus is automatically configured as a data source in Grafana when using kube-prometheus-stack.

### Application Instrumentation

#### Node.js Example

```javascript
const promClient = require('prom-client');

// Create metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status']
});

// Use in application
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    httpRequestDuration
      .labels(req.method, req.route?.path || 'unknown', res.statusCode)
      .observe((Date.now() - start) / 1000);
  });
  next();
});

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(await promClient.register.metrics());
});
```

#### Kubernetes ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sample-app
  namespace: devops-studio
spec:
  selector:
    matchLabels:
      app: sample-app
  endpoints:
    - port: http
      path: /metrics
      interval: 30s
```

## Best Practices

### Retention

- **Development**: 7-15 days
- **Production**: 30-90 days
- **Long-term**: Use Thanos or Cortex for extended retention

### Resource Sizing

- **Small cluster** (< 50 nodes): 2 CPU, 4GB RAM
- **Medium cluster** (50-200 nodes): 4 CPU, 8GB RAM
- **Large cluster** (> 200 nodes): 8+ CPU, 16GB+ RAM

### Scrape Intervals

- **High-frequency metrics**: 15-30s
- **Standard metrics**: 30-60s
- **Low-priority metrics**: 2-5 minutes

## Troubleshooting

### Prometheus Not Scraping

```bash
# Check Prometheus targets
# In Prometheus UI: Status > Targets

# Check ServiceMonitor
kubectl get servicemonitor -A

# Check pod annotations
kubectl get pod <pod-name> -o yaml | grep prometheus.io
```

### High Memory Usage

```bash
# Check memory usage
kubectl top pod -n observability -l app.kubernetes.io/name=prometheus

# Reduce retention
# Edit values.yaml: retention: 7d

# Reduce scrape interval
# Edit scrape configs
```

### Storage Issues

```bash
# Check PVC
kubectl get pvc -n observability

# Check storage usage
kubectl exec -n observability prometheus-0 -- df -h
```

## Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [PromQL Guide](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)

