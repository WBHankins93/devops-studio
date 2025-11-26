#!/bin/bash
# scripts/validate.sh
# Validate deployed EKS cluster and applications

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Validating EKS cluster and applications...${NC}"

# Check if kubectl is configured
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}❌ kubectl not configured. Run './scripts/configure-kubectl.sh' first.${NC}"
    exit 1
fi

ERRORS=0

# Test 1: Cluster Access
echo -e "${BLUE}1. Testing Cluster Access...${NC}"
if kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${GREEN}   ✅ Cluster is accessible${NC}"
else
    echo -e "${RED}   ❌ Cannot access cluster${NC}"
    ((ERRORS++))
fi

# Test 2: Node Health
echo -e "${BLUE}2. Testing Node Health...${NC}"
NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c " Ready " || echo "0")

if [ "$READY_NODES" -gt 0 ]; then
    echo -e "${GREEN}   ✅ $READY_NODES/$NODES nodes are Ready${NC}"
else
    echo -e "${RED}   ❌ No ready nodes found${NC}"
    ((ERRORS++))
fi

# Test 3: CoreDNS
echo -e "${BLUE}3. Testing CoreDNS...${NC}"
COREDNS_PODS=$(kubectl get pods -n kube-system -l k8s-app=kube-dns --no-headers 2>/dev/null | wc -l)
if [ "$COREDNS_PODS" -gt 0 ]; then
    RUNNING_COREDNS=$(kubectl get pods -n kube-system -l k8s-app=kube-dns --no-headers 2>/dev/null | grep -c " Running " || echo "0")
    if [ "$RUNNING_COREDNS" -gt 0 ]; then
        echo -e "${GREEN}   ✅ CoreDNS is running ($RUNNING_COREDNS pods)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  CoreDNS pods exist but not all running${NC}"
    fi
else
    echo -e "${RED}   ❌ CoreDNS not found${NC}"
    ((ERRORS++))
fi

# Test 4: Ingress Controller
echo -e "${BLUE}4. Testing Ingress Controller...${NC}"
INGRESS_PODS=$(kubectl get pods -n ingress-nginx --no-headers 2>/dev/null | wc -l)
if [ "$INGRESS_PODS" -gt 0 ]; then
    RUNNING_INGRESS=$(kubectl get pods -n ingress-nginx --no-headers 2>/dev/null | grep -c " Running " || echo "0")
    if [ "$RUNNING_INGRESS" -gt 0 ]; then
        echo -e "${GREEN}   ✅ Ingress controller is running ($RUNNING_INGRESS pods)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Ingress controller pods exist but not all running${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Ingress controller not found (may need to install)${NC}"
fi

# Test 5: Sample Application (if deployed)
echo -e "${BLUE}5. Testing Sample Application...${NC}"
SAMPLE_APP=$(kubectl get deployment sample-app -n devops-studio --no-headers 2>/dev/null | wc -l)
if [ "$SAMPLE_APP" -gt 0 ]; then
    AVAILABLE_REPLICAS=$(kubectl get deployment sample-app -n devops-studio -o jsonpath='{.status.availableReplicas}' 2>/dev/null || echo "0")
    DESIRED_REPLICAS=$(kubectl get deployment sample-app -n devops-studio -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
    if [ "$AVAILABLE_REPLICAS" -eq "$DESIRED_REPLICAS" ] && [ "$DESIRED_REPLICAS" -gt 0 ]; then
        echo -e "${GREEN}   ✅ Sample app is running ($AVAILABLE_REPLICAS/$DESIRED_REPLICAS replicas)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Sample app deployed but not all replicas available${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️  Sample application not deployed (run 'make deploy-app' to deploy)${NC}"
fi

# Test 6: Services
echo -e "${BLUE}6. Testing Services...${NC}"
SERVICES=$(kubectl get services --all-namespaces --no-headers 2>/dev/null | wc -l)
if [ "$SERVICES" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Found $SERVICES services${NC}"
else
    echo -e "${YELLOW}   ⚠️  No services found${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 All critical tests passed! Cluster is healthy.${NC}"
    echo ""
    echo -e "${BLUE}Cluster Summary:${NC}"
    kubectl get nodes
    echo ""
    kubectl get pods --all-namespaces | head -10
    exit 0
else
    echo -e "${RED}❌ Validation failed with $ERRORS error(s)${NC}"
    echo -e "${YELLOW}Please check the errors above and fix them.${NC}"
    exit 1
fi

