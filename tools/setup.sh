#!/bin/bash
# tools/setup.sh
# Interactive setup script for DevOps Studio platform

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         DevOps Studio - Platform Setup Script               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Step 1: Validate system requirements
echo -e "${BLUE}Step 1: Validating system requirements...${NC}"
./tools/validate.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ System validation failed. Please install required tools.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ System requirements validated${NC}"
echo ""

# Step 2: Check AWS configuration
echo -e "${BLUE}Step 2: Checking AWS configuration...${NC}"
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  AWS CLI not configured${NC}"
    echo -e "${BLUE}Please configure AWS CLI:${NC}"
    echo -e "  aws configure"
    echo ""
    read -p "Press Enter after configuring AWS CLI, or Ctrl+C to exit..."
    aws sts get-caller-identity >/dev/null 2>&1 || {
        echo -e "${RED}❌ AWS configuration still invalid${NC}"
        exit 1
    }
fi

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-west-2")
echo -e "${GREEN}✅ AWS configured${NC}"
echo -e "   Account: ${AWS_ACCOUNT}"
echo -e "   Region: ${AWS_REGION}"
echo ""

# Step 3: Choose lab
echo -e "${BLUE}Step 3: Choose your first lab${NC}"
echo ""
echo "Available labs:"
echo "  1) Lab 01 - Terraform Foundations (Recommended for beginners)"
echo "  2) Lab 02 - Kubernetes Platform"
echo "  3) Lab 03 - CI/CD Pipelines"
echo "  4) Lab 04 - Observability Stack"
echo "  5) Lab 05 - Security Automation"
echo "  6) Lab 06 - GitOps Workflows"
echo "  7) Lab 07 - Serverless Operations"
echo "  8) Lab 08 - Platform Engineering"
echo ""
read -p "Enter lab number (1-8) or press Enter for Lab 01: " LAB_CHOICE
LAB_CHOICE=${LAB_CHOICE:-1}

case $LAB_CHOICE in
    1) LAB_DIR="labs/01-terraform-foundations" ;;
    2) LAB_DIR="labs/02-kubernetes-platform" ;;
    3) LAB_DIR="labs/03-cicd-pipelines" ;;
    4) LAB_DIR="labs/04-observability-stack" ;;
    5) LAB_DIR="labs/05-security-automation" ;;
    6) LAB_DIR="labs/06-gitops-workflows" ;;
    7) LAB_DIR="labs/07-serverless-ops" ;;
    8) LAB_DIR="labs/08-platform-engineering" ;;
    *)
        echo -e "${RED}Invalid choice. Defaulting to Lab 01.${NC}"
        LAB_DIR="labs/01-terraform-foundations"
        ;;
esac

if [ ! -d "$LAB_DIR" ]; then
    echo -e "${RED}❌ Lab directory not found: $LAB_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Selected: $LAB_DIR${NC}"
echo ""

# Step 4: Lab-specific setup
echo -e "${BLUE}Step 4: Setting up $LAB_DIR...${NC}"
cd "$LAB_DIR"

# Check if lab has setup script
if [ -f "scripts/setup-backend.sh" ]; then
    echo -e "${BLUE}Running lab setup script...${NC}"
    chmod +x scripts/setup-backend.sh
    ./scripts/setup-backend.sh
else
    echo -e "${YELLOW}⚠️  No setup script found for this lab${NC}"
fi

cd - > /dev/null
echo ""

# Step 5: Summary
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Navigate to your lab:"
echo -e "     ${BLUE}cd $LAB_DIR${NC}"
echo -e "  2. Review the README:"
echo -e "     ${BLUE}cat README.md${NC}"
echo -e "  3. Customize configuration (if needed):"
echo -e "     ${BLUE}cp terraform.tfvars.example terraform.tfvars${NC}"
echo -e "     ${BLUE}# Edit terraform.tfvars${NC}"
echo -e "  4. Deploy infrastructure:"
echo -e "     ${BLUE}make apply${NC}"
echo ""
echo -e "${YELLOW}💡 Tip: Run 'make help' in the lab directory for available commands${NC}"
echo ""

