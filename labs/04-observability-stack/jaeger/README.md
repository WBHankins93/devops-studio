# Jaeger - Distributed Tracing

Jaeger is an open-source distributed tracing system used for monitoring and troubleshooting microservices-based distributed systems.

## Overview

Jaeger provides:
- **Distributed tracing** - Track requests across services
- **Service dependency mapping** - Visualize service relationships
- **Performance analysis** - Identify bottlenecks
- **Root cause analysis** - Debug issues in microservices

## Architecture

```
┌─────────────────────────────────────────────────┐
│         Application Services                     │
│  (Instrumented with OpenTelemetry/Jaeger)       │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
         ┌──────────────────┐
         │  Jaeger Agent     │
         │  (Collector)       │
         └────────┬──────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  Jaeger Collector │
         │  (Processing)      │
         └────────┬──────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  Storage Backend  │
         │  (Memory/DB)      │
         └────────┬──────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  Jaeger Query     │
         │  (UI)             │
         └──────────────────┘
```

## Installation

### Using Helm (Recommended)

```bash
# Add Jaeger Helm repository
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update

# Install Jaeger (all-in-one for development)
helm install jaeger jaegertracing/jaeger \
  --namespace observability \
  --create-namespace \
  --values values.yaml
```

### Storage Options

#### Memory (Development)

```yaml
storage:
  type: memory
```

#### Elasticsearch (Production)

```yaml
storage:
  type: elasticsearch
  elasticsearch:
    host: opensearch:9200
    scheme: http
```

#### Cassandra (Production)

```yaml
storage:
  type: cassandra
  cassandra:
    host: cassandra:9042
```

## Usage

### Access Jaeger UI

```bash
# Port forward to access UI
kubectl port-forward -n observability svc/jaeger-query 16686:16686

# Open in browser
open http://localhost:16686
```

### Instrumenting Applications

#### Node.js Example

```javascript
const { NodeTracerProvider } = require('@opentelemetry/sdk-trace-node');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');
const { Resource } = require('@opentelemetry/resources');
const { SemanticResourceAttributes } = require('@opentelemetry/semantic-conventions');

const provider = new NodeTracerProvider({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'sample-app',
  }),
});

const exporter = new JaegerExporter({
  endpoint: 'http://jaeger-agent:6831',
});

provider.addSpanProcessor(new BatchSpanProcessor(exporter));
provider.register();

// Use in Express
const { trace, context } = require('@opentelemetry/api');

app.get('/api/users', async (req, res) => {
  const tracer = trace.getTracer('sample-app');
  const span = tracer.startSpan('get-users');
  
  try {
    const users = await getUserData();
    span.setStatus({ code: SpanStatusCode.OK });
    res.json(users);
  } catch (error) {
    span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
    res.status(500).json({ error: error.message });
  } finally {
    span.end();
  }
});
```

#### Kubernetes Sidecar Injection

For Istio service mesh:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  annotations:
    sidecar.istio.io/inject: "true"
spec:
  # ... deployment spec
```

### Viewing Traces

1. Open Jaeger UI
2. Select service from dropdown
3. Click **Find Traces**
4. View trace timeline:
   - **Spans** - Individual operations
   - **Duration** - Time taken
   - **Tags** - Metadata
   - **Logs** - Span logs

### Service Dependencies

View service dependency graph:

1. Go to **Dependencies** tab
2. See service relationships
3. Identify bottlenecks

## Integration

### OpenTelemetry

Jaeger supports OpenTelemetry:

```yaml
# OpenTelemetry Collector configuration
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317

exporters:
  jaeger:
    endpoint: jaeger-collector:14250
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [jaeger]
```

### Grafana Integration

Add Jaeger as data source in Grafana:

1. Go to **Configuration** > **Data Sources**
2. Add **Jaeger** data source
3. URL: `http://jaeger-query:16686`
4. Use in Explore view for trace visualization

## Best Practices

### Sampling

Configure sampling to reduce overhead:

```yaml
sampling:
  type: probabilistic
  param: 0.1  # Sample 10% of traces
```

### Storage Retention

- **Development**: 1-7 days
- **Production**: 7-30 days
- Use external storage (Elasticsearch/Cassandra) for longer retention

### Performance

- Use async span processing
- Batch span exports
- Configure appropriate sampling rates
- Monitor Jaeger resource usage

## Troubleshooting

### No Traces Appearing

```bash
# Check Jaeger collector is running
kubectl get pods -n observability -l app.kubernetes.io/name=jaeger

# Check application is sending traces
# Verify endpoint: jaeger-agent:6831 (UDP)

# Check Jaeger logs
kubectl logs -n observability -l app.kubernetes.io/name=jaeger-collector
```

### High Memory Usage

```bash
# Check memory usage
kubectl top pods -n observability -l app.kubernetes.io/name=jaeger

# Reduce sampling rate
# Edit values.yaml: sampling.param: 0.05
```

## Additional Resources

- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Jaeger Best Practices](https://www.jaegertracing.io/docs/1.47/best-practices/)

