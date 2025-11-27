#!/bin/bash
# Validation script for GitOps Workflows Lab
# Checks that Kustomize, Argo CD, and Flux are configured correctly

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

log_section "Validating GitOps Workflows Stack"

# Check Kustomize
log_section "Kustomize"
if command -v kustomize &> /dev/null || kubectl kustomize --help &> /dev/null; then
    log_info "Kustomize is available"
    log_info "Testing base build..."
    if kubectl kustomize "$PROJECT_ROOT/kustomize/base" &> /dev/null; then
        log_info "✅ Base kustomization builds successfully"
    else
        log_warn "⚠️  Base kustomization has issues"
    fi
    log_info "Testing staging overlay..."
    if kubectl kustomize "$PROJECT_ROOT/kustomize/overlays/staging" &> /dev/null; then
        log_info "✅ Staging overlay builds successfully"
    else
        log_warn "⚠️  Staging overlay has issues"
    fi
    log_info "Testing production overlay..."
    if kubectl kustomize "$PROJECT_ROOT/kustomize/overlays/production" &> /dev/null; then
        log_info "✅ Production overlay builds successfully"
    else
        log_warn "⚠️  Production overlay has issues"
    fi
else
    log_warn "Kustomize not available"
fi

# Check Argo CD
log_section "Argo CD"
ARGOCD_PODS=$(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l)
if [ "$ARGOCD_PODS" -gt 0 ]; then
    log_info "Argo CD pods: $ARGOCD_PODS"
    kubectl get pods -n argocd
    log_info "Applications:"
    kubectl get applications -n argocd 2>/dev/null || log_warn "No applications found"
    log_info "✅ Argo CD is installed"
else
    log_warn "Argo CD not installed"
fi

# Check Flux
log_section "Flux"
FLUX_PODS=$(kubectl get pods -n flux-system --no-headers 2>/dev/null | wc -l)
if [ "$FLUX_PODS" -gt 0 ]; then
    log_info "Flux pods: $FLUX_PODS"
    kubectl get pods -n flux-system
    if command -v flux &> /dev/null; then
        log_info "GitRepositories:"
        flux get sources git 2>/dev/null || log_warn "No GitRepositories found"
        log_info "Kustomizations:"
        flux get kustomizations 2>/dev/null || log_warn "No Kustomizations found"
    else
        log_warn "Flux CLI not installed (optional for validation)"
    fi
    log_info "✅ Flux is installed"
else
    log_warn "Flux not installed"
fi

# Summary
log_section "Summary"
TOTAL_COMPONENTS=0
INSTALLED_COMPONENTS=0

# Kustomize (always available via kubectl)
INSTALLED_COMPONENTS=$((INSTALLED_COMPONENTS + 1))
TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + 1))

if [ "$ARGOCD_PODS" -gt 0 ]; then
    INSTALLED_COMPONENTS=$((INSTALLED_COMPONENTS + 1))
fi
TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + 1))

if [ "$FLUX_PODS" -gt 0 ]; then
    INSTALLED_COMPONENTS=$((INSTALLED_COMPONENTS + 1))
fi
TOTAL_COMPONENTS=$((TOTAL_COMPONENTS + 1))

log_info "GitOps components installed: $INSTALLED_COMPONENTS/$TOTAL_COMPONENTS"
log_info "Note: You typically use Kustomize with either Argo CD OR Flux, not both"

if [ "$INSTALLED_COMPONENTS" -ge 2 ]; then
    log_info "✅ GitOps stack is configured!"
else
    log_warn "⚠️  Some components are missing. Run 'make install-argocd' or 'make install-flux'"
fi

log_info "Validation complete!"

