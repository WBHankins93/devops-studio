#!/bin/bash
# Test script for CI/CD lab
# Runs unit and integration tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_DIR="$PROJECT_ROOT/app"

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

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed. Please install Node.js and try again."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    log_error "npm is not installed. Please install npm and try again."
    exit 1
fi

log_info "Running tests in $APP_DIR"

cd "$APP_DIR"

# Install dependencies
log_info "Installing dependencies..."
npm ci

# Run unit tests
log_info "Running unit tests..."
npm run test:unit || {
    log_error "Unit tests failed"
    exit 1
}

# Run integration tests
log_info "Running integration tests..."
npm run test:integration || {
    log_error "Integration tests failed"
    exit 1
}

log_info "All tests passed successfully!"

