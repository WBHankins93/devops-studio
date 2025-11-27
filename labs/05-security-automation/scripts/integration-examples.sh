#!/bin/bash
# Integration examples for security tools
# Demonstrates how security tools work together

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

NAMESPACE="devops-studio"

log_section "Security Integration Examples"

# Example 1: Complete Security Flow
log_section "Example 1: Complete Security Flow"
log_info "1. Build: Trivy scans image in CI/CD"
log_info "2. Deploy: OPA validates policies"
log_info "3. Runtime: Falco monitors behavior"
log_info "4. Access: RBAC controls permissions"

# Example 2: Test OPA Policy
log_section "Example 2: Test OPA Policy Enforcement"
log_info "Creating test pod without resource limits (should be rejected)..."
cat <<EOF | kubectl apply -f - 2>&1 | grep -q "denied" && log_info "✅ OPA rejected pod (policy working!)" || log_info "⚠️  Pod may have been created (check OPA status)"
apiVersion: v1
kind: Pod
metadata:
  name: test-opa-policy
  namespace: $NAMESPACE
spec:
  containers:
  - name: test
    image: nginx:latest
EOF

# Clean up
kubectl delete pod test-opa-policy -n "$NAMESPACE" --ignore-not-found=true

# Example 3: Test Falco Detection
log_section "Example 3: Falco Runtime Detection"
log_info "To test Falco:"
log_info "1. Create a pod: kubectl run test-pod --image=nginx:latest -n $NAMESPACE"
log_info "2. Execute shell: kubectl exec -it test-pod -n $NAMESPACE -- /bin/sh"
log_info "3. Check Falco logs: kubectl logs -n falco -l app=falco | grep shell"

# Example 4: Test RBAC
log_section "Example 4: RBAC Permission Check"
log_info "Checking service account permissions..."
if kubectl get serviceaccount app-service-account -n "$NAMESPACE" &> /dev/null; then
    kubectl auth can-i create pods --as=system:serviceaccount:$NAMESPACE:app-service-account
    kubectl auth can-i delete pods --as=system:serviceaccount:$NAMESPACE:app-service-account
else
    log_info "Service account not found. Create one to test RBAC."
fi

log_section "Integration Examples Complete"

