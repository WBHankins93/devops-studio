# EventBridge Configuration

This module configures EventBridge (formerly CloudWatch Events) for event-driven architecture.

## Overview

EventBridge provides:
- Event routing
- Scheduled events
- Custom event buses
- Event filtering

## Configuration

The EventBridge setup includes:
- Custom event bus
- Scheduled rule (every 5 minutes)
- Custom event rule
- Lambda function targets

## Usage

### Send Custom Event

```bash
aws events put-events \
  --entries '[{
    "Source": "devops-studio.dev",
    "DetailType": "Custom Event",
    "Detail": "{\"message\": \"Hello from EventBridge\"}"
  }]'
```

### Scheduled Events

Events are automatically triggered every 5 minutes. The Lambda function will process them.

## Monitoring

View EventBridge metrics in CloudWatch:
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Events \
  --metric-name Invocations \
  --dimensions Name=RuleName,Value=devops-studio-dev-scheduled-rule \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

## Best Practices

1. **Use Custom Buses** - Separate buses for different applications
2. **Filter Events** - Use event patterns to filter
3. **Monitor** - Track event delivery and failures
4. **Retry Logic** - Configure retries for failed events

