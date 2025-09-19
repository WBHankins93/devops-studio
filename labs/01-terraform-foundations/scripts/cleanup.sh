#!/bin/bash
# scripts/cleanup.sh
# Clean up all resources including backend

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}⚠️  DANGER: This will destroy ALL infrastructure and backend resources${NC}"
echo -e "${YELLOW}This includes:${NC}"
echo -e "  - All EC2 instances, load balancers, and VPC resources"
echo -e "  - S3 bucket with Terraform state"
echo -e "  - DynamoDB table for state locking"
echo -e "  - All data will be PERMANENTLY LOST"
echo ""

read -p "Are you absolutely sure? Type 'DELETE' to confirm: " -r
if [[ $REPLY != "DELETE" ]]; then
    echo -e "${YELLOW}Operation cancelled${NC}"
    exit 0
fi

echo -e "${BLUE}🗑️  Starting cleanup process...${NC}"

# Destroy infrastructure first
if [ -f "terraform.tfstate" ] || [ -f ".terraform/terraform.tfstate" ]; then
    echo -e "${BLUE}1. Destroying infrastructure...${NC}"
    terraform destroy -auto-approve
    echo -e "${GREEN}   ✅ Infrastructure destroyed${NC}"
else
    echo -e "${YELLOW}   ⚠️  No local state found, skipping infrastructure destroy${NC}"
fi

# Clean up backend resources
if [ -f "backend.tf" ]; then
    BUCKET_NAME=$(grep 'bucket.*=' backend.tf | sed 's/.*= *"\([^"]*\)".*/\1/')
    DYNAMODB_TABLE=$(grep 'dynamodb_table.*=' backend.tf | sed 's/.*= *"\([^"]*\)".*/\1/')
    REGION=$(grep 'region.*=' backend.tf | sed 's/.*= *"\([^"]*\)".*/\1/')
    
    if [ -n "$BUCKET_NAME" ]; then
        echo -e "${BLUE}2. Deleting S3 bucket: $BUCKET_NAME${NC}"
        # Delete all versions and delete markers
        aws s3api delete-objects \
            --bucket "$BUCKET_NAME" \
            --delete "$(aws s3api list-object-versions \
                --bucket "$BUCKET_NAME" \
                --query '{Objects: Versions[].{Key: Key, VersionId: VersionId}}' \
                --output json)" 2>/dev/null || true
        
        aws s3api delete-objects \
            --bucket "$BUCKET_NAME" \
            --delete "$(aws s3api list-object-versions \
                --bucket "$BUCKET_NAME" \
                --query '{Objects: DeleteMarkers[].{Key: Key, VersionId: VersionId}}' \
                --output json)" 2>/dev/null || true
        
        # Delete bucket
        aws s3 rb "s3://$BUCKET_NAME" --force
        echo -e "${GREEN}   ✅ S3 bucket deleted${NC}"
    fi
    
    if [ -n "$DYNAMODB_TABLE" ]; then
        echo -e "${BLUE}3. Deleting DynamoDB table: $DYNAMODB_TABLE${NC}"
        aws dynamodb delete-table --table-name "$DYNAMODB_TABLE" --region "$REGION" 2>/dev/null || true
        echo -e "${GREEN}   ✅ DynamoDB table deleted${NC}"
    fi
fi

# Clean up local files
echo -e "${BLUE}4. Cleaning up local files...${NC}"
rm -rf .terraform/
rm -f .terraform.lock.hcl
rm -f terraform.tfstate*
rm -f tfplan
rm -f backend.tf
rm -f terraform.tfvars
echo -e "${GREEN}   ✅ Local files cleaned${NC}"

echo -e "${GREEN}🎉 Cleanup complete! All resources have been destroyed.${NC}"

# Make script executable
chmod +x scripts/cleanup.sh
