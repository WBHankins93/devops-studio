#!/bin/bash
# Validation script for CI/CD lab
# Validates deployed application

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
NAMESPACE="${NAMESPACE:-devops-studio}"
IMAGE_NAME="${IMAGE_NAME:-devops-studio-app}"
MAX_RETRIES=10
RETRY_DELAY=5

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed. Please install kubectl and try again."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    log_error "Cannot connect to Kubernetes cluster. Please configure kubectl."
    exit 1
fi

log_info "Validating deployment: $IMAGE_NAME in namespace: $NAMESPACE"

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    log_error "Namespace $NAMESPACE does not exist"
    exit 1
fi

# Check if deployment exists
if ! kubectl get deployment "$IMAGE_NAME" -n "$NAMESPACE" &> /dev/null; then
    log_error "Deployment $IMAGE_NAME does not exist in namespace $NAMESPACE"
    exit 1
fi

# Check deployment status
log_info "Checking deployment status..."
DEPLOYMENT_STATUS=$(kubectl get deployment "$IMAGE_NAME" -n "$NAMESPACE" -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')
if [ "$DEPLOYMENT_STATUS" != "True" ]; then
    log_error "Deployment is not available"
    kubectl describe deployment "$IMAGE_NAME" -n "$NAMESPACE"
    exit 1
fi

# Check pod status
log_info "Checking pod status..."
PODS_READY=$(kubectl get pods -n "$NAMESPACE" -l app="$IMAGE_NAME" -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}')
for pod_status in $PODS_READY; do
    if [ "$pod_status" != "True" ]; then
        log_error "Not all pods are ready"
        kubectl get pods -n "$NAMESPACE" -l app="$IMAGE_NAME"
        exit 1
    fi
done

# Get service endpoint
log_info "Getting service endpoint..."
SERVICE_URL=$(kubectl get svc "$IMAGE_NAME" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    # Try to port-forward for local testing
    log_warn "Service does not have external endpoint. Using port-forward for validation..."
    kubectl port-forward svc/$IMAGE_NAME -n $NAMESPACE 8080:3000 &
    PORT_FORWARD_PID=$!
    sleep 2
    SERVICE_URL="localhost:8080"
    USE_PORT_FORWARD=true
else
    USE_PORT_FORWARD=false
fi

# Health check
log_info "Performing health check on $SERVICE_URL..."
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f -s "http://$SERVICE_URL/health" > /dev/null 2>&1; then
        log_info "Health check passed!"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        log_warn "Health check failed. Retrying in $RETRY_DELAY seconds... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep $RETRY_DELAY
    else
        log_error "Health check failed after $MAX_RETRIES attempts"
        if [ "$USE_PORT_FORWARD" = true ]; then
            kill $PORT_FORWARD_PID 2>/dev/null || true
        fi
        exit 1
    fi
done

# Test API endpoint
log_info "Testing API endpoint..."
if curl -f -s "http://$SERVICE_URL/api/status" > /dev/null 2>&1; then
    log_info "API endpoint test passed!"
else
    log_warn "API endpoint test failed (non-critical)"
fi

# Cleanup port-forward if used
if [ "$USE_PORT_FORWARD" = true ]; then
    kill $PORT_FORWARD_PID 2>/dev/null || true
fi

log_info "Validation completed successfully!"

