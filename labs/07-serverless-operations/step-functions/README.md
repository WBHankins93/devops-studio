# Step Functions Configuration

This module configures AWS Step Functions for workflow orchestration.

## Overview

Step Functions provides:
- Visual workflow designer
- Error handling and retries
- Parallel and sequential execution
- State management

## Workflow Definition

The state machine includes:
1. **HelloWorld** - Invokes hello-world Lambda
2. **ApiHandler** - Invokes api-handler Lambda
3. **ErrorHandler** - Handles errors

## Usage

### Start Execution

```bash
# Get state machine ARN
STATE_MACHINE_ARN=$(terraform output -raw step_functions_arn)

# Start execution
aws stepfunctions start-execution \
  --state-machine-arn $STATE_MACHINE_ARN \
  --input '{"key": "value"}'
```

### View Execution

```bash
# List executions
aws stepfunctions list-executions \
  --state-machine-arn $STATE_MACHINE_ARN

# Get execution details
aws stepfunctions describe-execution \
  --execution-arn <execution-arn>
```

## Monitoring

View Step Functions logs:
```bash
aws logs tail /aws/vendedlogs/states/devops-studio-dev-workflow --follow
```

## Best Practices

1. **Error Handling** - Use Retry and Catch blocks
2. **Idempotency** - Make steps safely retryable
3. **Timeouts** - Set appropriate timeouts
4. **Logging** - Enable execution logging
5. **Visual Design** - Use AWS Console for visual design

