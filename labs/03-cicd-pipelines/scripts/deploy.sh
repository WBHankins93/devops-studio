#!/bin/bash
# Deployment script for CI/CD lab
# Deploys application to Kubernetes cluster

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
K8S_DIR="$PROJECT_ROOT/k8s"

# Configuration
NAMESPACE="${NAMESPACE:-devops-studio}"
IMAGE_NAME="${IMAGE_NAME:-devops-studio-app}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
ENVIRONMENT="${ENVIRONMENT:-staging}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-5m}"

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

log_info "Deploying $IMAGE_NAME:$IMAGE_TAG to $ENVIRONMENT environment"

# Update deployment manifest with image tag and environment
log_info "Updating deployment manifest..."
cd "$K8S_DIR"
sed -i.bak "s|IMAGE_TAG|$IMAGE_TAG|g" deployment.yaml
sed -i.bak "s|ENVIRONMENT|$ENVIRONMENT|g" deployment.yaml

# Apply manifests
log_info "Applying Kubernetes manifests..."

kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# Wait for deployment
log_info "Waiting for deployment to complete (timeout: $WAIT_TIMEOUT)..."
kubectl rollout status deployment/$IMAGE_NAME -n $NAMESPACE --timeout=$WAIT_TIMEOUT || {
    log_error "Deployment failed or timed out"
    kubectl describe deployment/$IMAGE_NAME -n $NAMESPACE
    exit 1
}

# Verify deployment
log_info "Verifying deployment..."
kubectl get pods -n $NAMESPACE
kubectl get svc -n $NAMESPACE
kubectl get ingress -n $NAMESPACE

log_info "Deployment completed successfully!"

# Get service URL if available
SERVICE_URL=$(kubectl get svc $IMAGE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
if [ -n "$SERVICE_URL" ]; then
    log_info "Service URL: http://$SERVICE_URL"
fi

