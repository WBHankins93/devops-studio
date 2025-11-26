#!/bin/bash
# tools/cleanup.sh
# Emergency cleanup script for all DevOps Studio labs

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║           ⚠️  EMERGENCY CLEANUP SCRIPT ⚠️                   ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}This script will destroy ALL infrastructure from ALL labs!${NC}"
echo ""
echo -e "${YELLOW}What will be destroyed:${NC}"
echo -e "  • All EC2 instances, load balancers, and VPCs"
echo -e "  • All RDS databases (with data loss)"
echo -e "  • All EKS clusters and Kubernetes resources"
echo -e "  • All S3 buckets and DynamoDB tables"
echo -e "  • All CloudWatch logs and metrics"
echo -e "  • All other AWS resources created by labs"
echo ""
echo -e "${RED}This action CANNOT be undone!${NC}"
echo ""

read -p "Type 'DELETE ALL' to confirm: " CONFIRM
if [ "$CONFIRM" != "DELETE ALL" ]; then
    echo -e "${YELLOW}Operation cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🔍 Scanning for deployed labs...${NC}"
echo ""

# Find all labs with terraform state
LABS_DEPLOYED=0
CURRENT_DIR=$(pwd)

for lab_dir in labs/*/; do
    if [ -d "$lab_dir" ] && [ -f "$lab_dir/terraform.tfstate" ] || [ -d "$lab_dir/.terraform" ]; then
        LAB_NAME=$(basename "$lab_dir")
        echo -e "${BLUE}Found deployed lab: $LAB_NAME${NC}"
        ((LABS_DEPLOYED++))
        
        cd "$lab_dir"
        
        # Check if Makefile has destroy command
        if [ -f "Makefile" ] && grep -q "destroy:" Makefile; then
            echo -e "${YELLOW}  Destroying $LAB_NAME...${NC}"
            make destroy ENV=dev 2>/dev/null || {
                echo -e "${YELLOW}  Attempting direct terraform destroy...${NC}"
                terraform destroy -auto-approve 2>/dev/null || true
            }
        elif [ -f "terraform.tfstate" ] || [ -d ".terraform" ]; then
            echo -e "${YELLOW}  Destroying $LAB_NAME with terraform...${NC}"
            terraform destroy -auto-approve 2>/dev/null || true
        fi
        
        cd "$CURRENT_DIR"
    fi
done

if [ $LABS_DEPLOYED -eq 0 ]; then
    echo -e "${YELLOW}No deployed labs found${NC}"
else
    echo -e "${GREEN}✅ Cleaned up $LABS_DEPLOYED lab(s)${NC}"
fi

# Clean up orphaned resources by tags
echo ""
echo -e "${BLUE}🔍 Checking for orphaned resources...${NC}"

if aws sts get-caller-identity >/dev/null 2>&1; then
    # Find resources tagged with DevOps Studio
    echo -e "${BLUE}Searching for resources tagged 'Project=DevOps Studio'...${NC}"
    
    # EC2 instances
    INSTANCES=$(aws ec2 describe-instances \
        --filters "Name=tag:Project,Values=DevOps Studio" \
        --query 'Reservations[*].Instances[*].InstanceId' \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$INSTANCES" ] && [ "$INSTANCES" != "None" ]; then
        echo -e "${YELLOW}Found EC2 instances: $INSTANCES${NC}"
        for instance in $INSTANCES; do
            aws ec2 terminate-instances --instance-ids "$instance" 2>/dev/null || true
        done
    fi
    
    # RDS instances
    RDS_INSTANCES=$(aws rds describe-db-instances \
        --query 'DBInstances[?contains(DBInstanceIdentifier, `devops-studio`)].DBInstanceIdentifier' \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$RDS_INSTANCES" ] && [ "$RDS_INSTANCES" != "None" ]; then
        echo -e "${YELLOW}Found RDS instances: $RDS_INSTANCES${NC}"
        for db in $RDS_INSTANCES; do
            aws rds delete-db-instance \
                --db-instance-identifier "$db" \
                --skip-final-snapshot 2>/dev/null || true
        done
    fi
    
    # S3 buckets
    BUCKETS=$(aws s3api list-buckets \
        --query 'Buckets[?contains(Name, `devops-studio`) || contains(Name, `terraform-state`)].Name' \
        --output text 2>/dev/null || echo "")
    
    if [ -n "$BUCKETS" ] && [ "$BUCKETS" != "None" ]; then
        echo -e "${YELLOW}Found S3 buckets: $BUCKETS${NC}"
        for bucket in $BUCKETS; do
            aws s3 rb "s3://$bucket" --force 2>/dev/null || true
        done
    fi
fi

echo ""
echo -e "${GREEN}🎉 Cleanup complete!${NC}"
echo ""
echo -e "${BLUE}Note: Some resources may take a few minutes to fully terminate.${NC}"
echo -e "${BLUE}Check AWS Console to verify all resources are deleted.${NC}"
echo ""

