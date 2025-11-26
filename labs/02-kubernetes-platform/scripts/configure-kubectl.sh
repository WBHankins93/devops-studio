#!/bin/bash
# scripts/configure-kubectl.sh
# Configure kubectl to connect to the EKS cluster

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Configuring kubectl for EKS cluster...${NC}"

# Check if terraform outputs are available
if ! terraform output cluster_name >/dev/null 2>&1; then
    echo -e "${RED}❌ No Terraform outputs found. Deploy EKS cluster first with 'make apply'.${NC}"
    exit 1
fi

# Get cluster information
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region 2>/dev/null || echo "us-west-2")

echo -e "${BLUE}Cluster: ${CLUSTER_NAME}${NC}"
echo -e "${BLUE}Region: ${REGION}${NC}"

# Update kubeconfig
echo -e "${BLUE}Updating kubeconfig...${NC}"
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"

# Verify connection
echo -e "${BLUE}Verifying cluster connection...${NC}"
if kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Successfully connected to cluster${NC}"
    echo ""
    echo -e "${BLUE}Cluster Information:${NC}"
    kubectl cluster-info
    echo ""
    echo -e "${BLUE}Nodes:${NC}"
    kubectl get nodes
    echo ""
    echo -e "${GREEN}🎉 kubectl is now configured!${NC}"
    echo -e "${BLUE}Try these commands:${NC}"
    echo -e "  kubectl get nodes"
    echo -e "  kubectl get pods --all-namespaces"
    echo -e "  kubectl get services --all-namespaces"
else
    echo -e "${RED}❌ Failed to connect to cluster${NC}"
    echo -e "${YELLOW}Please check:${NC}"
    echo -e "  1. Cluster is fully deployed (wait 5-10 minutes after 'make apply')"
    echo -e "  2. AWS credentials are configured correctly"
    echo -e "  3. You have permissions to access the cluster"
    exit 1
fi

