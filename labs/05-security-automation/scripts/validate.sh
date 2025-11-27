#!/bin/bash
# Validation script for Security Automation Lab
# Checks that all security tools are running and configured correctly

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

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed. Please install kubectl and try again."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    log_error "Cannot connect to Kubernetes cluster. Please configure kubectl."
    exit 1
fi

log_section "Validating Security Automation Stack"

# Check Trivy
log_section "Trivy"
if command -v trivy &> /dev/null; then
    TRIVY_VERSION=$(trivy --version | head -n1)
    log_info "Trivy installed: $TRIVY_VERSION"
else
    log_warn "Trivy not installed (optional for local scanning)"
fi

# Check OPA Gatekeeper
log_section "OPA Gatekeeper"
GATEKEEPER_PODS=$(kubectl get pods -n gatekeeper-system --no-headers 2>/dev/null | wc -l)
if [ "$GATEKEEPER_PODS" -gt 0 ]; then
    log_info "Gatekeeper pods: $GATEKEEPER_PODS"
    kubectl get pods -n gatekeeper-system
    log_info "Constraint templates:"
    kubectl get constrainttemplate 2>/dev/null || log_warn "No constraint templates found"
    log_info "Constraints:"
    kubectl get constraint --all-namespaces 2>/dev/null || log_warn "No constraints found"
else
    log_warn "OPA Gatekeeper not installed"
fi

# Check Falco
log_section "Falco"
FALCO_PODS=$(kubectl get pods -n falco --no-headers 2>/dev/null | wc -l)
if [ "$FALCO_PODS" -gt 0 ]; then
    log_info "Falco pods: $FALCO_PODS"
    kubectl get pods -n falco
    log_info "Checking Falco rules..."
    FALCO_POD=$(kubectl get pods -n falco -l app=falco -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$FALCO_POD" ]; then
        kubectl exec -n falco "$FALCO_POD" -- falco --list-rules 2>/dev/null | head -5 || log_warn "Could not list Falco rules"
    fi
else
    log_warn "Falco not installed"
fi

# Check RBAC
log_section "RBAC"
log_info "Roles in devops-studio namespace:"
kubectl get roles -n devops-studio 2>/dev/null || log_warn "No roles found"
log_info "Role bindings in devops-studio namespace:"
kubectl get rolebindings -n devops-studio 2>/dev/null || log_warn "No role bindings found"
log_info "Service accounts in devops-studio namespace:"
kubectl get serviceaccounts -n devops-studio 2>/dev/null || log_warn "No service accounts found"

# Summary
log_section "Summary"
TOTAL_COMPONENTS=0
INSTALLED_COMPONENTS=0

if [ "$GATEKEEPER_PODS" -gt 0 ]; then
    INSTALLED_COMPONENTS=$((INSTALLED_COMPONENTS + 1))
fi
TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + 1))

if [ "$FALCO_PODS" -gt 0 ]; then
    INSTALLED_COMPONENTS=$((INSTALLED_COMPONENTS + 1))
fi
TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + 1))

log_info "Security components installed: $INSTALLED_COMPONENTS/$TOTAL_COMPONENTS"

if [ "$INSTALLED_COMPONENTS" -eq "$TOTAL_COMPONENTS" ]; then
    log_info "✅ All security components are installed!"
else
    log_warn "⚠️  Some security components are missing. Run 'make install-all' to install them."
fi

log_info "Validation complete!"

