# Grafana - Visualization and Dashboards

Grafana is an open-source analytics and visualization platform that allows you to query, visualize, alert on, and understand your metrics, logs, and traces.

## Overview

Grafana provides:
- **Unified dashboards** - Visualize metrics, logs, and traces
- **Multiple data sources** - Prometheus, OpenSearch, Jaeger, and more
- **Alerting** - Set up alerts based on metrics
- **Templating** - Dynamic dashboards with variables
- **Sharing** - Export and share dashboards

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Data Sources                         │
│  Prometheus | OpenSearch | Jaeger | ...          │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
         ┌──────────────────┐
         │   Grafana         │
         │   (Dashboards)     │
         └────────┬──────────┘
                  │
                  ▼
         ┌──────────────────┐
         │   Users           │
         │   (Visualization) │
         └──────────────────┘
```

## Installation

### Using Helm (Recommended)

```bash
# Add Grafana Helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Grafana
helm install grafana grafana/grafana \
  --namespace observability \
  --create-namespace \
  --values values.yaml
```

### Configuration

Edit `values.yaml` to customize:

```yaml
adminUser: admin
adminPassword: admin

persistence:
  enabled: true
  size: 10Gi

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-kube-prometheus-prometheus:9090
        access: proxy
        isDefault: true
```

## Usage

### Access Grafana UI

```bash
# Port forward to access UI
kubectl port-forward -n observability svc/grafana 3000:80

# Open in browser
open http://localhost:3000

# Default credentials
# Username: admin
# Password: admin (change on first login!)
```

### Data Sources

#### Prometheus

1. Go to **Configuration** > **Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. URL: `http://prometheus-kube-prometheus-prometheus:9090`
5. Click **Save & Test**

#### OpenSearch

1. Go to **Configuration** > **Data Sources**
2. Click **Add data source**
3. Select **OpenSearch**
4. URL: `http://opensearch:9200`
5. Index name: `kubernetes-logs-*`
6. Time field: `@timestamp`
7. Click **Save & Test**

#### Jaeger

1. Go to **Configuration** > **Data Sources**
2. Click **Add data source**
3. Select **Jaeger**
4. URL: `http://jaeger-query:16686`
5. Click **Save & Test**

### Pre-built Dashboards

#### Import Kubernetes Dashboard

1. Go to **Dashboards** > **Import**
2. Enter dashboard ID: `315` (Kubernetes Cluster Monitoring)
3. Select Prometheus data source
4. Click **Import**

#### Import Node Exporter Dashboard

1. Go to **Dashboards** > **Import**
2. Enter dashboard ID: `1860` (Node Exporter Full)
3. Select Prometheus data source
4. Click **Import**

### Creating Custom Dashboards

#### Example: Application Metrics Dashboard

1. Click **+** > **Create Dashboard**
2. Click **Add visualization**
3. Select **Prometheus** data source
4. Enter query: `rate(http_requests_total[5m])`
5. Configure visualization type (Graph, Stat, etc.)
6. Save dashboard

#### Dashboard Variables

Create dynamic dashboards with variables:

1. Go to **Dashboard Settings** > **Variables**
2. Click **Add variable**
3. Configure:
   - Name: `namespace`
   - Type: `Query`
   - Data source: `Prometheus`
   - Query: `label_values(kube_pod_info, namespace)`
4. Use in queries: `rate(http_requests_total{namespace="$namespace"}[5m])`

## Alerting

### Create Alert Rule

1. Go to **Alerting** > **Alert rules**
2. Click **New alert rule**
3. Configure:
   - **Name**: High CPU Usage
   - **Query**: `rate(container_cpu_usage_seconds_total[5m]) > 0.8`
   - **Condition**: When avg() of query(A, 5m, now) is above 0.8
   - **Evaluation**: Every 1m, For 5m
4. Add notification channel
5. Save

### Notification Channels

Configure notification channels:

1. Go to **Alerting** > **Notification channels**
2. Click **Add channel**
3. Configure:
   - **Name**: Slack
   - **Type**: Slack
   - **Webhook URL**: Your Slack webhook
4. Test and save

## Best Practices

### Dashboard Organization

- Use folders to organize dashboards
- Name dashboards clearly (e.g., "Kubernetes - Cluster Overview")
- Add descriptions to dashboards
- Tag dashboards for easy searching

### Performance

- Limit time range in queries
- Use recording rules for complex queries
- Avoid too many panels per dashboard
- Use data source query caching

### Security

- Change default admin password
- Use LDAP/OAuth for authentication
- Enable RBAC for team access
- Regularly backup dashboards

## Troubleshooting

### Cannot Connect to Data Source

```bash
# Check data source URL
# Verify service is accessible
kubectl get svc -n observability

# Test connectivity
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://prometheus-kube-prometheus-prometheus:9090/api/v1/status/config
```

### Dashboards Not Loading

- Check data source is configured correctly
- Verify queries are valid
- Check time range is appropriate
- Review Grafana logs: `kubectl logs -n observability -l app.kubernetes.io/name=grafana`

## Additional Resources

- [Grafana Documentation](https://grafana.com/docs/)
- [Grafana Dashboard Examples](https://grafana.com/grafana/dashboards/)
- [Grafana Alerting Guide](https://grafana.com/docs/grafana/latest/alerting/)

