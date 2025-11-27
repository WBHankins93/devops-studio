#!/bin/bash
# Test API Gateway endpoint

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Get API URL from Terraform output
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")

if [ -z "$API_URL" ]; then
    echo -e "${YELLOW}⚠️  API Gateway URL not found. Make sure Terraform has been applied.${NC}"
    exit 1
fi

log_section "Testing API Gateway"

# Test GET request
log_info "Testing GET request..."
curl -s -X GET "$API_URL/test" | jq '.' || echo "Response received"

# Test POST request
log_info "Testing POST request..."
curl -s -X POST "$API_URL/test" \
  -H "Content-Type: application/json" \
  -d '{"key": "value", "message": "Hello from API"}' | jq '.' || echo "Response received"

log_section "API Testing Complete"

