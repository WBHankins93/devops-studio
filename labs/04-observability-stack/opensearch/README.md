# OpenSearch - Log Aggregation and Search

OpenSearch is a distributed search and analytics engine derived from Elasticsearch. It's used for log aggregation, full-text search, and real-time analytics.

## Overview

OpenSearch provides:
- **Centralized log storage** - Aggregate logs from all services
- **Full-text search** - Fast search across log data
- **Real-time analytics** - Analyze logs as they arrive
- **Dashboards** - OpenSearch Dashboards for visualization
- **Scalability** - Handle large volumes of logs

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Application Services                 │
│  (Pods, Containers, Applications)                │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
         ┌──────────────────┐
         │  OpenSearch      │
         │  (Data Nodes)     │
         └────────┬──────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  OpenSearch       │
         │  Dashboards       │
         │  (UI)             │
         └──────────────────┘
```

## Installation

### Using Helm (Recommended)

```bash
# Add OpenSearch Helm repository
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update

# Install OpenSearch cluster
helm install opensearch opensearch/opensearch \
  --namespace observability \
  --create-namespace \
  --set persistence.enabled=true \
  --set persistence.size=20Gi

# Install OpenSearch Dashboards
helm install opensearch-dashboards opensearch/opensearch-dashboards \
  --namespace observability \
  --set opensearchHosts=https://opensearch:9200
```

### Using Kubernetes Manifests

```bash
# Apply OpenSearch manifests
kubectl apply -f manifests/opensearch-cluster.yaml
kubectl apply -f manifests/opensearch-dashboards.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=opensearch -n observability --timeout=300s
```

## Configuration

### Basic Configuration

Edit `config/opensearch-config.yaml`:

```yaml
cluster:
  name: opensearch-cluster
  initial_master_nodes:
    - opensearch-0
    - opensearch-1
    - opensearch-2

node:
  roles:
    - master
    - data
    - ingest

plugins:
  - repository-s3  # For S3 backup
  - analysis-icu
```

### Resource Requirements

Minimum for development:
- **CPU**: 2 cores per node
- **Memory**: 4GB per node
- **Storage**: 20GB per node

Production recommendations:
- **CPU**: 4+ cores per node
- **Memory**: 8GB+ per node
- **Storage**: 100GB+ per node (SSD recommended)

## Usage

### Access OpenSearch Dashboards

```bash
# Port forward to access UI
kubectl port-forward svc/opensearch-dashboards -n observability 5601:5601

# Open in browser
open http://localhost:5601
```

Default credentials:
- **Username**: admin
- **Password**: admin (change in production!)

### Send Logs to OpenSearch

#### Using Fluent Bit (Recommended)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: observability
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         1
        Log_Level     info
        Daemon        off

    [INPUT]
        Name              tail
        Path              /var/log/containers/*.log
        Parser            docker
        Tag               kube.*
        Refresh_Interval  5

    [OUTPUT]
        Name  opensearch
        Match *
        Host  opensearch.observability.svc.cluster.local
        Port  9200
        Index kubernetes-logs
        Type  _doc
```

#### Using Logstash

```ruby
input {
  beats {
    port => 5044
  }
}

output {
  opensearch {
    hosts => ["opensearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
}
```

### Query Logs

#### Using OpenSearch Dashboards

1. Navigate to **Discover**
2. Select index pattern (e.g., `kubernetes-logs-*`)
3. Search using KQL (Kibana Query Language):
   ```
   level: ERROR AND service: api-gateway
   ```

#### Using cURL

```bash
# Search for errors
curl -X GET "opensearch:9200/kubernetes-logs/_search?q=level:ERROR" \
  -u admin:admin

# Get log count by service
curl -X GET "opensearch:9200/kubernetes-logs/_search" \
  -u admin:admin \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 0,
    "aggs": {
      "by_service": {
        "terms": {
          "field": "service.keyword"
        }
      }
    }
  }'
```

## Integration with Other Tools

### Grafana Integration

Add OpenSearch as a data source in Grafana:

1. Go to **Configuration** > **Data Sources**
2. Add **OpenSearch** data source
3. Configure:
   - URL: `http://opensearch:9200`
   - Access: Server (default)
   - Index name: `kubernetes-logs-*`
   - Time field: `@timestamp`

### Prometheus Integration

OpenSearch exposes metrics that Prometheus can scrape:

```yaml
# prometheus-config.yaml
scrape_configs:
  - job_name: 'opensearch'
    static_configs:
      - targets: ['opensearch:9200']
    metrics_path: '/_prometheus/metrics'
```

## Best Practices

### Index Management

1. **Use index templates** for consistent structure
2. **Set up index lifecycle management** (ILM) for retention
3. **Use date-based indices** (e.g., `logs-2024-01-15`)

### Performance Optimization

1. **Shard sizing**: 20-50GB per shard
2. **Replica count**: 1 for dev, 2+ for production
3. **Refresh interval**: Increase for high-volume logs
4. **Use hot/warm/cold tiers** for cost optimization

### Security

1. **Enable authentication** (required in production)
2. **Use TLS** for transport security
3. **Implement RBAC** for access control
4. **Rotate credentials** regularly

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -n observability -l app=opensearch

# Check logs
kubectl logs -n observability opensearch-0

# Check events
kubectl describe pod -n observability opensearch-0
```

### High Memory Usage

```bash
# Check memory usage
kubectl top pods -n observability

# Adjust heap size in config
# heap_size: 2g  # Should be ~50% of container memory
```

### Connection Issues

```bash
# Test connectivity
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl -u admin:admin http://opensearch:9200/_cluster/health

# Check service endpoints
kubectl get endpoints -n observability opensearch
```

## Cost Considerations

### Storage Costs

- **Development**: ~$5-10/month (20GB storage)
- **Production**: ~$50-200/month (100-500GB storage)
- **Backup**: Additional S3 costs

### Optimization Tips

1. **Set retention policies** (delete old logs)
2. **Use compression** for indices
3. **Archive old logs** to S3
4. **Use smaller node sizes** for dev/test

## Additional Resources

- [OpenSearch Documentation](https://opensearch.org/docs/)
- [OpenSearch Dashboards Guide](https://opensearch.org/docs/dashboards/)
- [Fluent Bit OpenSearch Output](https://docs.fluentbit.io/manual/pipeline/outputs/opensearch)

