# Platform Metrics

Custom CloudWatch metrics for platform monitoring.

## Metric Definitions

### Provisioning Metrics

- `Platform.Provisioning.Success` - Successful provisions
- `Platform.Provisioning.Failure` - Failed provisions
- `Platform.Provisioning.Duration` - Time to provision

### API Metrics

- `Platform.API.Requests` - API request count
- `Platform.API.Latency` - API response time
- `Platform.API.Errors` - API error count

### Resource Metrics

- `Platform.Resources.Count` - Total resource count
- `Platform.Resources.Cost` - Resource costs
- `Platform.Resources.Utilization` - Resource utilization

## Metric Files

Metric definitions and custom metric scripts would be stored here.

Example:
- `provisioning-metrics.json` - Provisioning metric definitions
- `api-metrics.json` - API metric definitions
- `cost-metrics.json` - Cost metric definitions

## Publishing Metrics

```bash
aws cloudwatch put-metric-data \
  --namespace Platform \
  --metric-name Provisioning.Success \
  --value 1 \
  --unit Count
```

