#!/bin/bash
# GitOps testing script
# Tests that GitOps tools are working correctly

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

log_section "GitOps Testing"

# Test 1: Kustomize Build
log_section "Test 1: Kustomize Build"
log_info "Building staging configuration..."
if kubectl kustomize "$PROJECT_ROOT/kustomize/overlays/staging" > /dev/null 2>&1; then
    log_info "✅ Staging configuration builds successfully"
else
    log_error "❌ Staging configuration build failed"
    exit 1
fi

log_info "Building production configuration..."
if kubectl kustomize "$PROJECT_ROOT/kustomize/overlays/production" > /dev/null 2>&1; then
    log_info "✅ Production configuration builds successfully"
else
    log_error "❌ Production configuration build failed"
    exit 1
fi

# Test 2: Argo CD
log_section "Test 2: Argo CD"
ARGOCD_PODS=$(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l)
if [ "$ARGOCD_PODS" -gt 0 ]; then
    log_info "Checking Argo CD applications..."
    APPLICATIONS=$(kubectl get applications -n argocd --no-headers 2>/dev/null | wc -l)
    if [ "$APPLICATIONS" -gt 0 ]; then
        log_info "✅ Argo CD has $APPLICATIONS application(s) configured"
        kubectl get applications -n argocd
    else
        log_warn "⚠️  Argo CD is installed but no applications configured"
    fi
else
    log_warn "Argo CD not installed, skipping test"
fi

# Test 3: Flux
log_section "Test 3: Flux"
FLUX_PODS=$(kubectl get pods -n flux-system --no-headers 2>/dev/null | wc -l)
if [ "$FLUX_PODS" -gt 0 ]; then
    log_info "Checking Flux resources..."
    if command -v flux &> /dev/null; then
        GIT_REPOS=$(flux get sources git --no-headers 2>/dev/null | wc -l)
        KUSTOMIZATIONS=$(flux get kustomizations --no-headers 2>/dev/null | wc -l)
        if [ "$GIT_REPOS" -gt 0 ] && [ "$KUSTOMIZATIONS" -gt 0 ]; then
            log_info "✅ Flux has $GIT_REPOS GitRepository(ies) and $KUSTOMIZATIONS Kustomization(s)"
        else
            log_warn "⚠️  Flux is installed but resources not configured"
        fi
    else
        log_warn "Flux CLI not installed, checking via kubectl..."
        GIT_REPOS=$(kubectl get gitrepositories -n flux-system --no-headers 2>/dev/null | wc -l)
        KUSTOMIZATIONS=$(kubectl get kustomizations -n flux-system --no-headers 2>/dev/null | wc -l)
        if [ "$GIT_REPOS" -gt 0 ] && [ "$KUSTOMIZATIONS" -gt 0 ]; then
            log_info "✅ Flux has $GIT_REPOS GitRepository(ies) and $KUSTOMIZATIONS Kustomization(s)"
        else
            log_warn "⚠️  Flux is installed but resources not configured"
        fi
    fi
else
    log_warn "Flux not installed, skipping test"
fi

# Test 4: Manual Deployment Test
log_section "Test 4: Manual Deployment Test"
log_info "Testing manual deployment with Kustomize..."
log_info "This would deploy to staging namespace (dry-run):"
kubectl kustomize "$PROJECT_ROOT/kustomize/overlays/staging" | kubectl apply --dry-run=client -f - > /dev/null 2>&1
if [ $? -eq 0 ]; then
    log_info "✅ Manual deployment test passed"
else
    log_warn "⚠️  Manual deployment test had issues"
fi

log_section "GitOps Testing Complete"
log_info "All tests completed!"

