#!/bin/bash
# Validation script for Observability Stack
# Checks that all components are running and accessible

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NAMESPACE="observability"

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

log_section "Validating Observability Stack"

# Check namespace
log_info "Checking namespace..."
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    log_error "Namespace $NAMESPACE does not exist"
    exit 1
fi

# Check Prometheus
log_section "Prometheus"
PROMETHEUS_PODS=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=prometheus --no-headers 2>/dev/null | wc -l)
if [ "$PROMETHEUS_PODS" -gt 0 ]; then
    log_info "Prometheus pods: $PROMETHEUS_PODS"
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=prometheus
else
    log_warn "Prometheus not found"
fi

# Check Grafana
log_section "Grafana"
GRAFANA_PODS=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=grafana --no-headers 2>/dev/null | wc -l)
if [ "$GRAFANA_PODS" -gt 0 ]; then
    log_info "Grafana pods: $GRAFANA_PODS"
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=grafana
else
    log_warn "Grafana not found"
fi

# Check Jaeger
log_section "Jaeger"
JAEGER_PODS=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=jaeger --no-headers 2>/dev/null | wc -l)
if [ "$JAEGER_PODS" -gt 0 ]; then
    log_info "Jaeger pods: $JAEGER_PODS"
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=jaeger
else
    log_warn "Jaeger not found"
fi

# Check OpenSearch
log_section "OpenSearch"
OPENSEARCH_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=opensearch --no-headers 2>/dev/null | wc -l)
if [ "$OPENSEARCH_PODS" -gt 0 ]; then
    log_info "OpenSearch pods: $OPENSEARCH_PODS"
    kubectl get pods -n "$NAMESPACE" -l app=opensearch
else
    log_warn "OpenSearch not found"
fi

# Check Fluent Bit
log_section "Fluent Bit"
FLUENT_BIT_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=fluent-bit --no-headers 2>/dev/null | wc -l)
if [ "$FLUENT_BIT_PODS" -gt 0 ]; then
    log_info "Fluent Bit pods: $FLUENT_BIT_PODS"
    kubectl get pods -n "$NAMESPACE" -l app=fluent-bit
else
    log_warn "Fluent Bit not found"
fi

# Check services
log_section "Services"
log_info "Checking services..."
kubectl get svc -n "$NAMESPACE"

# Summary
log_section "Summary"
TOTAL_PODS=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
RUNNING_PODS=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)

log_info "Total pods: $TOTAL_PODS"
log_info "Running pods: $RUNNING_PODS"

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
    log_info "✅ All pods are running!"
else
    log_warn "⚠️  Some pods may not be running"
    kubectl get pods -n "$NAMESPACE"
fi

log_info "Validation complete!"

