# Lab 04 - Observability Stack
*Complete Monitoring, Logging, and Tracing with Prometheus, Grafana, Jaeger, and OpenSearch*

> **Navigation**: [DevOps Studio](../../README.md) > [Labs](../README.md) > Lab 04  
> **Previous Lab**: [Lab 03 - CI/CD Pipelines](../03-cicd-pipelines/README.md)  
> **Next Lab**: [Lab 05 - Security Automation](../05-security-automation/README.md)

[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus)](https://prometheus.io)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana)](https://grafana.com)
[![Jaeger](https://img.shields.io/badge/Jaeger-1296C2?logo=jaeger)](https://www.jaegertracing.io)
[![OpenSearch](https://img.shields.io/badge/OpenSearch-005571?logo=opensearch)](https://opensearch.org)

> **Objective**: Deploy a complete observability stack covering the three pillars of observability: metrics (Prometheus), visualization (Grafana), distributed tracing (Jaeger), and log aggregation (OpenSearch). Learn to monitor, debug, and optimize your Kubernetes applications and infrastructure.

---

## 📑 Table of Contents

- [Overview](#overview)
- [What You'll Learn](#what-youll-learn)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Project Structure](#project-structure)
- [Components](#components)
- [Integration](#integration)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)
- [Learning Objectives](#learning-objectives)
- [Best Practices Demonstrated](#best-practices-demonstrated)
- [Cost Considerations](#cost-considerations)
- [Next Steps](#next-steps)
- [Additional Resources](#additional-resources)

---

## Overview

This lab deploys a production-ready observability stack that provides complete visibility into your Kubernetes cluster and applications. You'll learn how to collect metrics, aggregate logs, trace requests, and visualize everything in dashboards.

### What Gets Built

- **Prometheus** - Metrics collection and time-series database
- **Grafana** - Visualization and dashboards
- **Jaeger** - Distributed tracing system
- **OpenSearch** - Log aggregation and search engine
- **Fluent Bit** - Log collection and forwarding
- **Integrated Dashboards** - Pre-configured monitoring views

### Key Features

- ✅ **Three Pillars of Observability**: Metrics, Logs, and Traces
- ✅ **Production Patterns**: Real enterprise-grade configurations
- ✅ **Kubernetes Native**: Built for Kubernetes environments
- ✅ **Integrated Stack**: All components work together
- ✅ **Well Documented**: Clear examples and use cases

---

## What You'll Learn

### Observability Fundamentals
- The three pillars: Metrics, Logs, Traces
- When to use each data type
- How they complement each other

### Prometheus (Metrics)
- Metrics collection and scraping
- PromQL query language
- Alerting rules
- Service discovery

### Grafana (Visualization)
- Dashboard creation
- Data source configuration
- Alerting and notifications
- Panel types and visualizations

### Jaeger (Distributed Tracing)
- Request tracing across services
- Service dependency mapping
- Performance bottleneck identification
- Trace analysis

### OpenSearch (Log Aggregation)
- Centralized log storage
- Full-text search
- Log analysis and dashboards
- Index management

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Services                      │
│         (Pods, Containers, Microservices)                     │
└──────────────┬──────────────────────────────┬──────────────┘
               │                               │
               ▼                               ▼
    ┌──────────────────┐          ┌──────────────────┐
    │   Prometheus      │          │   Fluent Bit      │
    │   (Metrics)       │          │   (Log Collector) │
    └─────────┬─────────┘          └─────────┬─────────┘
              │                              │
              │                              ▼
              │                   ┌──────────────────┐
              │                   │   OpenSearch     │
              │                   │   (Log Storage)   │
              │                   └─────────┬────────┘
              │                             │
              ▼                             │
    ┌──────────────────┐                   │
    │   Jaeger         │                   │
    │   (Traces)       │                   │
    └─────────┬────────┘                   │
              │                            │
              └────────────┬───────────────┘
                           │
                           ▼
                  ┌──────────────────┐
                  │   Grafana         │
                  │   (Visualization) │
                  └──────────────────┘
```

### Data Flow

1. **Metrics**: Applications → Prometheus → Grafana
2. **Logs**: Applications → Fluent Bit → OpenSearch → Grafana
3. **Traces**: Applications → Jaeger → Grafana

---

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **kubectl** | 1.28+ | Kubernetes cluster management |
| **Helm** | 3.10+ | Package management |
| **curl** | Latest | API testing |

### AWS Requirements

- **EKS Cluster** from Lab 02 (or existing Kubernetes cluster)
- **kubectl** configured to access the cluster

### Knowledge Prerequisites

- Basic Kubernetes concepts
- Understanding of Lab 02 (Kubernetes Platform)
- Basic understanding of monitoring concepts

### Lab Dependencies

**Required**: Complete [Lab 02](../02-kubernetes-platform/) first to have an EKS cluster.

---

## Quick Start

For experienced users who want to deploy immediately:

```bash
# 1. Navigate to lab directory
cd labs/04-observability-stack

# 2. Install complete stack
make install-all

# 3. Access dashboards (in separate terminals)
kubectl port-forward -n observability svc/grafana 3000:80
kubectl port-forward -n observability svc/prometheus-kube-prometheus-prometheus 9090:9090
kubectl port-forward -n observability svc/jaeger-query 16686:16686
kubectl port-forward -n observability svc/opensearch-dashboards 5601:5601

# 4. Open in browser
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090
# Jaeger: http://localhost:16686
# OpenSearch: http://localhost:5601 (admin/admin)
```

**Setup time**: ~10-15 minutes  
**Estimated cost**: $2-5 to complete (vs $40-60/month if kept running)

---

## Detailed Setup

### Step 1: Verify Cluster Access

```bash
# Check kubectl is configured
kubectl cluster-info
kubectl get nodes
```

### Step 2: Install Components

You can install components individually or all at once:

```bash
# Install all at once (recommended)
make install-all

# Or install individually
make install-prometheus
make install-grafana
make install-jaeger
make install-opensearch
```

### Step 3: Verify Installation

```bash
# Check status
make status

# Or manually
kubectl get pods -n observability
```

---

## Project Structure

```
labs/04-observability-stack/
├── README.md                    # This file
├── Makefile                     # Automation commands
├── prometheus/                  # Prometheus configurations
│   └── (Helm chart)
├── grafana/                     # Grafana configurations
│   └── (Helm chart)
├── jaeger/                      # Jaeger configurations
│   └── (Helm chart)
├── opensearch/                  # OpenSearch configurations
│   ├── README.md               # OpenSearch guide
│   ├── manifests/              # Kubernetes manifests
│   │   ├── opensearch-cluster.yaml
│   │   ├── opensearch-dashboards.yaml
│   │   └── fluent-bit-config.yaml
│   └── config/                 # Configuration files
└── scripts/                     # Automation scripts
```

---

## Components

### Prometheus (Metrics)

**What it does**: Collects and stores metrics as time-series data.

**Key Features**:
- Scrapes metrics from services
- Stores time-series data
- PromQL query language
- Alerting rules

**Access**: `kubectl port-forward -n observability svc/prometheus-kube-prometheus-prometheus 9090:9090`

### Grafana (Visualization)

**What it does**: Creates dashboards and visualizations from metrics, logs, and traces.

**Key Features**:
- Connect to Prometheus, OpenSearch, Jaeger
- Pre-built dashboards
- Custom dashboard creation
- Alerting

**Access**: `kubectl port-forward -n observability svc/grafana 3000:80`  
**Credentials**: admin / admin

### Jaeger (Distributed Tracing)

**What it does**: Traces requests across multiple services in microservices architectures.

**Key Features**:
- Request flow visualization
- Service dependency mapping
- Performance bottleneck identification
- Trace search and analysis

**Access**: `kubectl port-forward -n observability svc/jaeger-query 16686:16686`

### OpenSearch (Log Aggregation)

**What it does**: Stores, searches, and analyzes application logs.

**Key Features**:
- Centralized log storage
- Full-text search
- Real-time log analysis
- OpenSearch Dashboards UI

**Access**: `kubectl port-forward -n observability svc/opensearch-dashboards 5601:5601`  
**Credentials**: admin / admin

See [opensearch/README.md](opensearch/README.md) for detailed OpenSearch documentation.

---

## Integration

### Grafana Data Sources

Grafana can connect to all components:

1. **Prometheus**: Metrics visualization
2. **OpenSearch**: Log queries and dashboards
3. **Jaeger**: Trace visualization

### Complete Observability

With all components, you can:
- **Monitor** system health (Prometheus + Grafana)
- **Search** application logs (OpenSearch)
- **Trace** request flows (Jaeger)
- **Visualize** everything (Grafana)

---

## Usage Examples

### Query Metrics in Prometheus

```promql
# CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Memory usage
container_memory_usage_bytes

# Request rate
rate(http_requests_total[5m])
```

### Search Logs in OpenSearch

```bash
# Search for errors
curl -X GET "opensearch:9200/kubernetes-logs/_search?q=level:ERROR" \
  -u admin:admin

# Get logs by service
curl -X GET "opensearch:9200/kubernetes-logs/_search" \
  -u admin:admin \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "match": {
        "kubernetes.labels.app": "sample-app"
      }
    }
  }'
```

### View Traces in Jaeger

1. Open Jaeger UI
2. Select service
3. Click "Find Traces"
4. View trace timeline and spans

---

## Troubleshooting

### Components Not Starting

```bash
# Check pod status
kubectl get pods -n observability

# Check logs
kubectl logs -n observability <pod-name>

# Check events
kubectl describe pod -n observability <pod-name>
```

### High Resource Usage

```bash
# Check resource usage
kubectl top pods -n observability

# Adjust resource limits in manifests
```

### Connection Issues

```bash
# Test service connectivity
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://opensearch:9200/_cluster/health
```

---

## Cleanup

### Remove All Components

```bash
# Uninstall everything
make uninstall-all

# Or manually
kubectl delete namespace observability
```

---

## Learning Objectives

### Beginner Level ✅
After completing this lab, you should understand:
- What observability means
- The three pillars (metrics, logs, traces)
- Basic dashboard creation
- Log search and analysis

### Intermediate Level ✅
You should be able to:
- Create custom Grafana dashboards
- Write PromQL queries
- Configure log aggregation
- Set up distributed tracing

### Advanced Level ✅
You should master:
- Complete observability stack design
- Performance optimization
- Alerting configuration
- Integration patterns

---

## Best Practices Demonstrated

### Observability
- ✅ **Three Pillars**: Metrics, Logs, Traces
- ✅ **Centralized Collection**: All data in one place
- ✅ **Integrated Visualization**: Single pane of glass
- ✅ **Production Ready**: Scalable configurations

### Monitoring
- ✅ **Comprehensive Coverage**: Infrastructure and applications
- ✅ **Real-time Insights**: Live dashboards
- ✅ **Historical Analysis**: Time-series data retention
- ✅ **Alerting**: Proactive issue detection

---

## Cost Considerations

### Estimated Costs

**Monthly Cost** (if running continuously): ~$40-60
- Prometheus: $10-15/month
- Grafana: $5-10/month
- Jaeger: $5-10/month
- OpenSearch: $20-30/month (storage)

**Cost to Complete** (run for 2-3 hours): ~$2-5
- Component deployment: Minimal
- Storage: Negligible for short-term
- Compute: Included in cluster costs

### Cost Optimization

- Use smaller node sizes for dev/test
- Set log retention policies
- Archive old logs to S3
- Use managed services (AWS OpenSearch Service) for production

---

## Next Steps

### Immediate Next Actions
1. **Explore dashboards** in Grafana
2. **Search logs** in OpenSearch
3. **View traces** in Jaeger
4. **Create custom dashboards**

### Continue Your Learning Journey

#### Next Recommended Lab
- **[Lab 05 - Security Automation](../05-security-automation/README.md)** - Secure your observability stack

#### Related Labs
- **[Lab 02: Kubernetes Platform](../02-kubernetes-platform/README.md)** - Monitor this cluster
- **[Lab 03: CI/CD Pipelines](../03-cicd-pipelines/README.md)** - Monitor deployments

---

## Additional Resources

### Documentation
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [Jaeger Docs](https://www.jaegertracing.io/docs/)
- [OpenSearch Docs](https://opensearch.org/docs/)

### Learning Resources
- [Observability Tools Explained](../../docs/observability-tools-explained.md) - Understanding metrics, logs, and traces
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboard Examples](https://grafana.com/grafana/dashboards/)

---

**🎉 Congratulations!** You've deployed a complete observability stack covering metrics, logs, and traces. You now have full visibility into your applications and infrastructure!

**Ready for the next challenge?** Continue to [Lab 05 - Security Automation](../05-security-automation/) to secure your platform!

