#!/bin/bash
# Validation script for Platform Engineering Lab
# Checks that platform infrastructure is deployed correctly

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

log_section "Validating Platform Engineering Infrastructure"

# Get project name and environment from Terraform
PROJECT_NAME=$(terraform output -raw project_name 2>/dev/null || echo "devops-studio")
ENVIRONMENT=$(terraform output -raw environment 2>/dev/null || echo "dev")

# Check S3 bucket for state
log_section "Platform State Storage"
STATE_BUCKET=$(terraform output -raw platform_state_bucket 2>/dev/null || echo "")
if [ -n "$STATE_BUCKET" ]; then
    if aws s3 ls "s3://${STATE_BUCKET}" &> /dev/null; then
        log_info "✅ State bucket exists: $STATE_BUCKET"
    else
        log_warn "⚠️  State bucket not accessible: $STATE_BUCKET"
    fi
else
    log_warn "⚠️  State bucket not found in Terraform outputs"
fi

# Check DynamoDB table for state locking
log_section "State Locking"
LOCK_TABLE=$(terraform output -raw platform_state_lock_table 2>/dev/null || echo "")
if [ -n "$LOCK_TABLE" ]; then
    if aws dynamodb describe-table --table-name "$LOCK_TABLE" &> /dev/null; then
        log_info "✅ State lock table exists: $LOCK_TABLE"
    else
        log_warn "⚠️  State lock table not found: $LOCK_TABLE"
    fi
else
    log_warn "⚠️  State lock table not found in Terraform outputs"
fi

# Check IAM role
log_section "IAM Role"
ROLE_ARN=$(terraform output -raw platform_automation_role_arn 2>/dev/null || echo "")
if [ -n "$ROLE_ARN" ]; then
    ROLE_NAME=$(echo "$ROLE_ARN" | awk -F'/' '{print $NF}')
    if aws iam get-role --role-name "$ROLE_NAME" &> /dev/null; then
        log_info "✅ Platform automation role exists: $ROLE_NAME"
    else
        log_warn "⚠️  Platform automation role not found: $ROLE_NAME"
    fi
else
    log_warn "⚠️  Platform automation role not found in Terraform outputs"
fi

# Check SSM parameter
log_section "Platform Configuration"
CONFIG_PARAM=$(terraform output -raw platform_config_parameter 2>/dev/null || echo "")
if [ -n "$CONFIG_PARAM" ]; then
    if aws ssm get-parameter --name "$CONFIG_PARAM" &> /dev/null; then
        log_info "✅ Platform configuration parameter exists: $CONFIG_PARAM"
    else
        log_warn "⚠️  Platform configuration parameter not found: $CONFIG_PARAM"
    fi
else
    log_warn "⚠️  Platform configuration parameter not found in Terraform outputs"
fi

# Check service catalog
log_section "Service Catalog"
if [ -d "$PROJECT_ROOT/service-catalog" ]; then
    TEMPLATE_COUNT=$(find "$PROJECT_ROOT/service-catalog" -name "main.tf" -type f | wc -l)
    log_info "✅ Service catalog templates found: $TEMPLATE_COUNT"
else
    log_warn "⚠️  Service catalog directory not found"
fi

# Summary
log_section "Summary"
log_info "Platform infrastructure validation complete!"
log_info "Review the output above for any missing components."
log_info ""
log_info "Next steps:"
log_info "1. Review service catalog templates"
log_info "2. Set up developer portal (optional)"
log_info "3. Configure platform APIs"
log_info "4. Set up monitoring dashboards"

