# Monitoring and Observability

This document explains monitoring setup for serverless applications.

## CloudWatch Logs

All Lambda functions automatically log to CloudWatch Logs.

### View Logs

```bash
# Hello World function
aws logs tail /aws/lambda/devops-studio-dev-hello-world --follow

# API Handler function
aws logs tail /aws/lambda/devops-studio-dev-api-handler --follow

# Event Processor function
aws logs tail /aws/lambda/devops-studio-dev-event-processor --follow
```

## CloudWatch Metrics

### Lambda Metrics

Monitor:
- **Invocations** - Number of function invocations
- **Duration** - Execution time
- **Errors** - Number of errors
- **Throttles** - Number of throttled invocations

### View Metrics

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=devops-studio-dev-hello-world \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

## CloudWatch Dashboards

Create dashboards to visualize:
- Lambda invocations
- Error rates
- Duration
- API Gateway requests
- DynamoDB operations

## X-Ray Tracing

Enable X-Ray for distributed tracing:

```python
from aws_xray_sdk.core import xray_recorder

@xray_recorder.capture('my_function')
def my_function():
    # Your code
    pass
```

## Cost Monitoring

### AWS Cost Explorer

Monitor costs by:
- Service (Lambda, API Gateway, DynamoDB)
- Function name
- Time period

### Billing Alarms

Set up billing alarms to get notified of unexpected costs.

## Best Practices

1. **Enable Logging** - Always enable CloudWatch Logs
2. **Set Alarms** - Monitor error rates and duration
3. **Use Dashboards** - Visualize metrics
4. **Enable X-Ray** - For distributed tracing
5. **Monitor Costs** - Track spending regularly

