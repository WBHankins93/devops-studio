#!/bin/bash
# Build script for CI/CD lab
# Builds Docker image and optionally pushes to registry

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$PROJECT_ROOT/app"

# Configuration
IMAGE_NAME="${IMAGE_NAME:-devops-studio-app}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-}"
PUSH_IMAGE="${PUSH_IMAGE:-false}"

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

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

log_info "Building Docker image: $IMAGE_NAME:$IMAGE_TAG"

# Build image
cd "$APP_DIR"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

log_info "Image built successfully: $IMAGE_NAME:$IMAGE_TAG"

# Push to registry if requested
if [ "$PUSH_IMAGE" = "true" ] && [ -n "$DOCKER_REGISTRY" ]; then
    log_info "Pushing image to registry: $DOCKER_REGISTRY"
    
    # Tag image with registry
    FULL_IMAGE_NAME="$DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
    docker tag "$IMAGE_NAME:$IMAGE_TAG" "$FULL_IMAGE_NAME"
    
    # Push image
    docker push "$FULL_IMAGE_NAME"
    
    log_info "Image pushed successfully: $FULL_IMAGE_NAME"
fi

log_info "Build completed successfully!"

