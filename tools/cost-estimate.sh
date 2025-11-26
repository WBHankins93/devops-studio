#!/bin/bash
# tools/cost-estimate.sh
# Estimate monthly costs for DevOps Studio labs

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         DevOps Studio - Cost Estimation Tool                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if infracost is installed
if ! command -v infracost >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  infracost not installed${NC}"
    echo -e "${BLUE}Installing infracost...${NC}"
    echo ""
    echo "For macOS:"
    echo "  brew install infracost"
    echo ""
    echo "For Linux:"
    echo "  bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh)\""
    echo ""
    echo "For more options: https://www.infracost.io/docs/"
    echo ""
    read -p "Press Enter to continue with manual estimates, or Ctrl+C to install infracost..."
    USE_INFRACOST=false
else
    USE_INFRACOST=true
    echo -e "${GREEN}✅ infracost found${NC}"
    echo ""
fi

# Cost estimates (us-west-2 pricing, approximate)
declare -A LAB_COSTS=(
    ["01-terraform-foundations"]="50-80"
    ["02-kubernetes-platform"]="120-180"
    ["03-cicd-pipelines"]="20-40"
    ["04-observability-stack"]="40-60"
    ["05-security-automation"]="30-50"
    ["06-gitops-workflows"]="20-30"
    ["07-serverless-ops"]="25-45"
    ["08-platform-engineering"]="80-120"
)

echo -e "${BLUE}Cost Estimates (Monthly, USD, us-west-2):${NC}"
echo ""

TOTAL_MIN=0
TOTAL_MAX=0

for lab in labs/*/; do
    if [ -d "$lab" ]; then
        LAB_NAME=$(basename "$lab")
        COST_RANGE=${LAB_COSTS[$LAB_NAME]:-"N/A"}
        
        if [ "$COST_RANGE" != "N/A" ]; then
            MIN=$(echo $COST_RANGE | cut -d'-' -f1)
            MAX=$(echo $COST_RANGE | cut -d'-' -f2)
            TOTAL_MIN=$((TOTAL_MIN + MIN))
            TOTAL_MAX=$((TOTAL_MAX + MAX))
            
            printf "  ${CYAN}%-35s${NC} $%s-$%s/month\n" "$LAB_NAME" "$MIN" "$MAX"
            
            # Use infracost if available and terraform files exist
            if [ "$USE_INFRACOST" = true ] && [ -f "$lab/main.tf" ]; then
                echo -e "    ${BLUE}Running infracost analysis...${NC}"
                cd "$lab"
                if [ -f "environments/dev.tfvars" ]; then
                    infracost breakdown --path . --terraform-var-file environments/dev.tfvars --format table 2>/dev/null | tail -5 || true
                else
                    infracost breakdown --path . --format table 2>/dev/null | tail -5 || true
                fi
                cd - > /dev/null
                echo ""
            fi
        fi
    fi
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
printf "${CYAN}Total (All Labs):${NC} $%s-$%s/month\n" "$TOTAL_MIN" "$TOTAL_MAX"
echo ""

# Cost optimization tips
echo -e "${YELLOW}💡 Cost Optimization Tips:${NC}"
echo -e "  • Use t3.micro instances for development"
echo -e "  • Scale down to 0 instances when not in use"
echo -e "  • Use single NAT Gateway for dev environments"
echo -e "  • Enable deletion protection only for production"
echo -e "  • Clean up resources regularly with: ./tools/cleanup.sh"
echo -e "  • Use AWS Free Tier where possible (first 12 months)"
echo ""

# AWS Free Tier information
echo -e "${BLUE}AWS Free Tier (New Accounts, First 12 Months):${NC}"
echo -e "  • EC2: 750 hours/month of t2.micro or t3.micro"
echo -e "  • RDS: 750 hours/month of db.t2.micro or db.t3.micro"
echo -e "  • S3: 5GB storage, 20,000 GET requests"
echo -e "  • Lambda: 1M free requests, 400,000 GB-seconds"
echo ""

echo -e "${GREEN}For detailed cost analysis, install infracost and run:${NC}"
echo -e "  ${BLUE}cd labs/01-terraform-foundations${NC}"
echo -e "  ${BLUE}infracost breakdown --path .${NC}"
echo ""

