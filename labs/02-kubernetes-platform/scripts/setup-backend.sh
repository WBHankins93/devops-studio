#!/bin/bash
# scripts/setup-backend.sh
# Set up Terraform backend (S3 bucket and DynamoDB table) for EKS lab

set -e

# Configuration
PROJECT_NAME="devops-studio"
REGION="us-west-2"
BUCKET_NAME="${PROJECT_NAME}-terraform-state-$(date +%s)"
DYNAMODB_TABLE="${PROJECT_NAME}-terraform-locks"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up Terraform backend for EKS lab...${NC}"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${RED}❌ AWS CLI not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

# Check if bucket already exists
EXISTING_BUCKET=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, '${PROJECT_NAME}-terraform-state')].Name" --output text | head -1)

if [ -n "$EXISTING_BUCKET" ]; then
    echo -e "${YELLOW}⚠️  Found existing bucket: $EXISTING_BUCKET${NC}"
    BUCKET_NAME="$EXISTING_BUCKET"
else
    echo -e "${BLUE}📦 Creating S3 bucket: ${BUCKET_NAME}${NC}"
    
    # Create bucket
    aws s3 mb "s3://${BUCKET_NAME}" --region "${REGION}"
    
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "${BUCKET_NAME}" \
        --versioning-configuration Status=Enabled
    
    # Enable server-side encryption
    aws s3api put-bucket-encryption \
        --bucket "${BUCKET_NAME}" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "${BUCKET_NAME}" \
        --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
    
    echo -e "${GREEN}✅ S3 bucket created and configured${NC}"
fi

# Check if DynamoDB table exists
if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${REGION}" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  DynamoDB table ${DYNAMODB_TABLE} already exists${NC}"
else
    echo -e "${BLUE}🗃️  Creating DynamoDB table: ${DYNAMODB_TABLE}${NC}"
    
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "${REGION}"
    
    # Wait for table to be active
    echo -e "${BLUE}⏳ Waiting for DynamoDB table to be active...${NC}"
    aws dynamodb wait table-exists --table-name "${DYNAMODB_TABLE}" --region "${REGION}"
    
    echo -e "${GREEN}✅ DynamoDB table created${NC}"
fi

# Update backend.tf file
echo -e "${BLUE}📝 Updating backend.tf configuration...${NC}"

cat > backend.tf << EOF
terraform {
  required_version = ">= 1.5"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  backend "s3" {
    bucket         = "${BUCKET_NAME}"
    key            = "labs/02-kubernetes-platform/terraform.tfstate"
    region         = "${REGION}"
    encrypt        = true
    dynamodb_table = "${DYNAMODB_TABLE}"
  }
}
EOF

echo -e "${GREEN}✅ Backend configuration updated${NC}"

# Create terraform.tfvars if it doesn't exist
if [ ! -f terraform.tfvars ]; then
    echo -e "${BLUE}📋 Creating terraform.tfvars file...${NC}"
    
    cat > terraform.tfvars << EOF
# Basic Configuration
environment = "dev"
project_name = "${PROJECT_NAME}"
region = "${REGION}"

# EKS Configuration
cluster_version = "1.28"
node_instance_type = "t3.medium"
node_min_size = 1
node_max_size = 3
node_desired_size = 2

# Networking
vpc_cidr = "10.1.0.0/16"
availability_zones = ["${REGION}a", "${REGION}b"]

# Tagging
tags = {
  Project = "DevOps Studio"
  Owner = "$(whoami)"
  Environment = "Development"
  ManagedBy = "Terraform"
}
EOF
    
    echo -e "${GREEN}✅ terraform.tfvars created${NC}"
else
    echo -e "${YELLOW}⚠️  terraform.tfvars already exists, skipping creation${NC}"
fi

echo -e "${GREEN}🎉 Backend setup complete!${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Review and customize terraform.tfvars"
echo -e "  2. Run: terraform init"
echo -e "  3. Run: make plan"
echo -e "  4. Run: make apply"

