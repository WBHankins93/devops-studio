#!/bin/bash
# shared/scripts/common.sh
# Common utility functions for DevOps Studio scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check AWS CLI configuration
check_aws_config() {
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log_error "AWS CLI not configured"
        return 1
    fi
    return 0
}

# Get AWS account ID
get_aws_account_id() {
    aws sts get-caller-identity --query Account --output text 2>/dev/null
}

# Get AWS region
get_aws_region() {
    aws configure get region 2>/dev/null || echo "us-west-2"
}

# Validate Terraform configuration
validate_terraform() {
    local dir=${1:-.}
    log_info "Validating Terraform in $dir"
    
    if ! command_exists terraform; then
        log_error "Terraform not found"
        return 1
    fi
    
    cd "$dir" || return 1
    
    terraform init -backend=false >/dev/null 2>&1 || {
        log_error "Terraform init failed"
        cd - >/dev/null
        return 1
    }
    
    terraform validate >/dev/null 2>&1 || {
        log_error "Terraform validation failed"
        cd - >/dev/null
        return 1
    }
    
    log_success "Terraform validation passed"
    cd - >/dev/null
    return 0
}

# Confirm action
confirm() {
    local message=$1
    read -p "$message (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Get project root directory
get_project_root() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(cd "$script_dir/../.." && pwd)"
}

