#!/bin/bash
# tools/bootstrap.sh
# Bootstrap script for initial project setup

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         DevOps Studio - Bootstrap Script                    ║"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Make all scripts executable
echo -e "${BLUE}Making scripts executable...${NC}"
find . -name "*.sh" -type f -exec chmod +x {} \;
echo -e "${GREEN}✅ Scripts are now executable${NC}"
echo ""

# Validate system
echo -e "${BLUE}Validating system requirements...${NC}"
./tools/validate.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ System validation failed${NC}"
    exit 1
fi
echo ""

# Check git configuration
echo -e "${BLUE}Checking Git configuration...${NC}"
if ! git config user.name >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Git user.name not configured${NC}"
    read -p "Enter your name for Git commits: " GIT_NAME
    git config user.name "$GIT_NAME"
fi

if ! git config user.email >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Git user.email not configured${NC}"
    read -p "Enter your email for Git commits: " GIT_EMAIL
    git config user.email "$GIT_EMAIL"
fi

echo -e "${GREEN}✅ Git configured${NC}"
echo -e "   Name: $(git config user.name)"
echo -e "   Email: $(git config user.email)"
echo ""

# Create .gitattributes if it doesn't exist
if [ ! -f ".gitattributes" ]; then
    echo -e "${BLUE}Creating .gitattributes...${NC}"
    cat > .gitattributes << 'EOF'
# Auto detect text files and perform LF normalization
* text=auto

# Shell scripts
*.sh text eol=lf

# Terraform files
*.tf text eol=lf
*.tfvars text eol=lf

# Documentation
*.md text eol=lf
*.txt text eol=lf

# Configuration files
*.yml text eol=lf
*.yaml text eol=lf
*.json text eol=lf
EOF
    echo -e "${GREEN}✅ .gitattributes created${NC}"
    echo ""
fi

# Summary
echo -e "${GREEN}🎉 Bootstrap complete!${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Run setup script:"
echo -e "     ${BLUE}./tools/setup.sh${NC}"
echo -e "  2. Or start with a specific lab:"
echo -e "     ${BLUE}cd labs/01-terraform-foundations${NC}"
echo -e "     ${BLUE}./scripts/setup-backend.sh${NC}"
echo ""

