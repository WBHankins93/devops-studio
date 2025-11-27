#!/bin/bash
# Validation script for Serverless Operations Lab
# Checks that all serverless components are deployed correctly

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    log_error "AWS CLI is not installed. Please install AWS CLI and try again."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    log_error "AWS credentials not configured. Run 'aws configure' and try again."
    exit 1
fi

log_section "Validating Serverless Operations Stack"

# Check Lambda Functions
log_section "Lambda Functions"
FUNCTIONS=("hello-world" "api-handler" "event-processor")
for func in "${FUNCTIONS[@]}"; do
    if aws lambda get-function --function-name "devops-studio-dev-${func}" &> /dev/null; then
        log_info "✅ ${func} function exists"
        # Get function configuration
        CONFIG=$(aws lambda get-function-configuration --function-name "devops-studio-dev-${func}")
        RUNTIME=$(echo $CONFIG | jq -r '.Runtime')
        MEMORY=$(echo $CONFIG | jq -r '.MemorySize')
        TIMEOUT=$(echo $CONFIG | jq -r '.Timeout')
        log_info "   Runtime: $RUNTIME, Memory: ${MEMORY}MB, Timeout: ${TIMEOUT}s"
    else
        log_warn "⚠️  ${func} function not found"
    fi
done

# Check API Gateway
log_section "API Gateway"
API_IDS=$(aws apigateway get-rest-apis --query 'items[?name==`devops-studio-dev-api`].id' --output text 2>/dev/null || echo "")
if [ -n "$API_IDS" ]; then
    log_info "✅ API Gateway exists"
    for API_ID in $API_IDS; do
        log_info "   API ID: $API_ID"
    done
else
    log_warn "⚠️  API Gateway not found"
fi

# Check DynamoDB
log_section "DynamoDB"
if aws dynamodb describe-table --table-name "devops-studio-dev-events" &> /dev/null; then
    log_info "✅ Events table exists"
    TABLE_INFO=$(aws dynamodb describe-table --table-name "devops-studio-dev-events")
    STATUS=$(echo $TABLE_INFO | jq -r '.Table.TableStatus')
    BILLING=$(echo $TABLE_INFO | jq -r '.Table.BillingModeSummary.BillingMode')
    log_info "   Status: $STATUS, Billing: $BILLING"
else
    log_warn "⚠️  Events table not found"
fi

# Check EventBridge
log_section "EventBridge"
if aws events describe-event-bus --name "devops-studio-dev-bus" &> /dev/null; then
    log_info "✅ EventBridge bus exists"
else
    log_warn "⚠️  EventBridge bus not found"
fi

# Check Step Functions
log_section "Step Functions"
if aws stepfunctions describe-state-machine --state-machine-arn "arn:aws:states:*:*:stateMachine:devops-studio-dev-workflow" &> /dev/null 2>&1; then
    log_info "✅ Step Functions state machine exists"
else
    STATE_MACHINES=$(aws stepfunctions list-state-machines --query 'stateMachines[?contains(name, `devops-studio-dev-workflow`)].stateMachineArn' --output text 2>/dev/null || echo "")
    if [ -n "$STATE_MACHINES" ]; then
        log_info "✅ Step Functions state machine exists"
    else
        log_warn "⚠️  Step Functions state machine not found"
    fi
fi

# Summary
log_section "Summary"
log_info "Validation complete!"
log_info "Check the output above for any missing components."

