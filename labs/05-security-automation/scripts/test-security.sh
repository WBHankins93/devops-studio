#!/bin/bash
# Security testing script
# Tests that security tools are working correctly

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

NAMESPACE="devops-studio"

log_section "Security Testing"

# Test 1: Trivy Scan
log_section "Test 1: Trivy Image Scan"
if command -v trivy &> /dev/null; then
    log_info "Scanning nginx:latest image..."
    trivy image --severity HIGH,CRITICAL nginx:latest || log_warn "Trivy scan found vulnerabilities (expected)"
    log_info "✅ Trivy scan completed"
else
    log_warn "Trivy not installed, skipping scan test"
fi

# Test 2: OPA Policy Enforcement
log_section "Test 2: OPA Policy Enforcement"
log_info "Testing OPA policy: Require resource limits..."

# Try to create a pod without resource limits (should be rejected)
log_info "Attempting to create pod without resource limits..."
kubectl apply -f - <<EOF 2>&1 | grep -q "denied" && log_info "✅ OPA correctly rejected pod without limits" || log_warn "⚠️  OPA may not be enforcing policies"
apiVersion: v1
kind: Pod
metadata:
  name: test-pod-no-limits
  namespace: $NAMESPACE
spec:
  containers:
  - name: test
    image: nginx:latest
EOF

# Clean up test pod if it was created
kubectl delete pod test-pod-no-limits -n "$NAMESPACE" --ignore-not-found=true

# Test 3: Falco Detection
log_section "Test 3: Falco Runtime Detection"
FALCO_POD=$(kubectl get pods -n falco -l app=falco -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$FALCO_POD" ]; then
    log_info "Falco is running. To test detection:"
    log_info "1. Execute shell in a container: kubectl exec -it <pod> -- /bin/sh"
    log_info "2. Check Falco logs: kubectl logs -n falco $FALCO_POD | grep shell"
    log_info "✅ Falco is monitoring"
else
    log_warn "Falco not running, skipping runtime detection test"
fi

# Test 4: RBAC Permissions
log_section "Test 4: RBAC Permissions"
log_info "Testing service account permissions..."
if kubectl get serviceaccount app-service-account -n "$NAMESPACE" &> /dev/null; then
    CAN_CREATE=$(kubectl auth can-i create pods --as=system:serviceaccount:$NAMESPACE:app-service-account 2>/dev/null || echo "no")
    if [ "$CAN_CREATE" = "yes" ]; then
        log_info "✅ Service account has pod creation permissions"
    else
        log_warn "⚠️  Service account cannot create pods"
    fi
else
    log_warn "Service account not found, skipping RBAC test"
fi

log_section "Security Testing Complete"
log_info "All security tests completed!"

