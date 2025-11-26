#!/bin/bash
# tools/validate.sh
# Validate system requirements for DevOps Studio

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Track validation status
ERRORS=0
WARNINGS=0

echo -e "${BLUE}🔍 Validating DevOps Studio system requirements...${NC}"
echo ""

# Function to check command
check_command() {
    local cmd=$1
    local min_version=$2
    local version_flag=${3:---version}
    
    if command -v "$cmd" >/dev/null 2>&1; then
        VERSION=$($cmd $version_flag 2>&1 | head -1)
        echo -e "${GREEN}✅ $cmd${NC}"
        echo -e "   $VERSION"
        
        # Version check if min_version provided
        if [ -n "$min_version" ]; then
            # Simple version comparison (can be enhanced)
            echo -e "   ${BLUE}Required: >= $min_version${NC}"
        fi
        return 0
    else
        echo -e "${RED}❌ $cmd not found${NC}"
        echo -e "   ${YELLOW}Installation: See docs/prerequisites.md${NC}"
        ((ERRORS++))
        return 1
    fi
}

# Required tools
echo -e "${BLUE}Required Tools:${NC}"
check_command "aws" "2.0" "--version" || true
check_command "terraform" "1.5" "--version" || true
check_command "git" "2.0" "--version" || true
check_command "curl" "" "--version" || true
echo ""

# Optional but recommended tools
echo -e "${BLUE}Optional Tools (Recommended):${NC}"
if command -v "kubectl" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ kubectl${NC}"
    kubectl version --client 2>&1 | head -1
else
    echo -e "${YELLOW}⚠️  kubectl not found (needed for Lab 02+)${NC}"
    ((WARNINGS++))
fi

if command -v "helm" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ helm${NC}"
    helm version --short 2>&1 | head -1
else
    echo -e "${YELLOW}⚠️  helm not found (needed for Lab 02+)${NC}"
    ((WARNINGS++))
fi

if command -v "docker" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ docker${NC}"
    docker --version
else
    echo -e "${YELLOW}⚠️  docker not found (needed for Lab 03+)${NC}"
    ((WARNINGS++))
fi

if command -v "jq" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ jq${NC}"
    jq --version
else
    echo -e "${YELLOW}⚠️  jq not found (helpful for JSON processing)${NC}"
    ((WARNINGS++))
fi
echo ""

# Check AWS configuration
echo -e "${BLUE}AWS Configuration:${NC}"
if aws sts get-caller-identity >/dev/null 2>&1; then
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "unknown")
    AWS_USER=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null || echo "unknown")
    AWS_REGION=$(aws configure get region 2>/dev/null || echo "not set")
    
    echo -e "${GREEN}✅ AWS CLI configured${NC}"
    echo -e "   Account: $AWS_ACCOUNT"
    echo -e "   Identity: $AWS_USER"
    echo -e "   Region: $AWS_REGION"
else
    echo -e "${RED}❌ AWS CLI not configured${NC}"
    echo -e "   ${YELLOW}Run: aws configure${NC}"
    ((ERRORS++))
fi
echo ""

# Check disk space (at least 5GB free)
echo -e "${BLUE}System Resources:${NC}"
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -ge 5 ]; then
    echo -e "${GREEN}✅ Disk space: ${AVAILABLE_SPACE}GB available${NC}"
else
    echo -e "${YELLOW}⚠️  Low disk space: ${AVAILABLE_SPACE}GB (recommend 5GB+)${NC}"
    ((WARNINGS++))
fi

# Check memory (basic check)
TOTAL_MEM=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
if [ "$TOTAL_MEM" -gt 0 ]; then
    TOTAL_MEM_GB=$((TOTAL_MEM / 1024 / 1024 / 1024))
    if [ "$TOTAL_MEM_GB" -ge 4 ]; then
        echo -e "${GREEN}✅ Memory: ${TOTAL_MEM_GB}GB${NC}"
    else
        echo -e "${YELLOW}⚠️  Low memory: ${TOTAL_MEM_GB}GB (recommend 4GB+)${NC}"
        ((WARNINGS++))
    fi
fi
echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! You're ready to start.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Validation complete with $WARNINGS warning(s)${NC}"
    echo -e "${YELLOW}   You can proceed, but some features may not work.${NC}"
    exit 0
else
    echo -e "${RED}❌ Validation failed with $ERRORS error(s)${NC}"
    echo -e "${RED}   Please fix the errors above before proceeding.${NC}"
    exit 1
fi

