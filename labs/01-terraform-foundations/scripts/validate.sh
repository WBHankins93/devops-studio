#!/bin/bash
# scripts/validate.sh
# Validate deployed infrastructure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Validating deployed infrastructure...${NC}"

# Check if Terraform outputs are available
if ! terraform output load_balancer_dns >/dev/null 2>&1; then
    echo -e "${RED}❌ No Terraform outputs found. Deploy infrastructure first.${NC}"
    exit 1
fi

# Get outputs
ALB_DNS=$(terraform output -raw load_balancer_dns)
PROJECT_NAME=$(terraform output -raw project_name)
ENVIRONMENT=$(terraform output -raw environment)

echo -e "${BLUE}📊 Testing infrastructure components...${NC}"

# Test 1: Load Balancer Health
echo -e "${BLUE}1. Testing Load Balancer...${NC}"
if curl -s -o /dev/null -w "%{http_code}" "http://${ALB_DNS}/health" | grep -q "200"; then
    echo -e "${GREEN}   ✅ Load Balancer health check passed${NC}"
else
    echo -e "${RED}   ❌ Load Balancer health check failed${NC}"
    exit 1
fi

# Test 2: Application Response
echo -e "${BLUE}2. Testing Application Response...${NC}"
RESPONSE=$(curl -s "http://${ALB_DNS}/")
if echo "$RESPONSE" | grep -q "DevOps Studio"; then
    echo -e "${GREEN}   ✅ Application responding correctly${NC}"
else
    echo -e "${RED}   ❌ Application not responding correctly${NC}"
    exit 1
fi

# Test 3: Auto Scaling Group
echo -e "${BLUE}3. Testing Auto Scaling Group...${NC}"
ASG_NAME="${PROJECT_NAME}-${ENVIRONMENT}-asg"
INSTANCES=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query 'AutoScalingGroups[0].Instances[?LifecycleState==`InService`]' \
    --output text | wc -l)

if [ "$INSTANCES" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Auto Scaling Group has $INSTANCES healthy instances${NC}"
else
    echo -e "${RED}   ❌ No healthy instances in Auto Scaling Group${NC}"
    exit 1
fi

# Test 4: Database Connectivity
echo -e "${BLUE}4. Testing Database...${NC}"
DB_ENDPOINT=$(terraform output -raw db_endpoint 2>/dev/null || echo "")
if [ -n "$DB_ENDPOINT" ]; then
    # Test database connection (simplified check)
    if aws rds describe-db-instances \
        --db-instance-identifier "${PROJECT_NAME}-${ENVIRONMENT}-db" \
        --query 'DBInstances[0].DBInstanceStatus' \
        --output text | grep -q "available"; then
        echo -e "${GREEN}   ✅ Database is available${NC}"
    else
        echo -e "${RED}   ❌ Database is not available${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}   ⚠️  Database endpoint not found, skipping test${NC}"
fi

# Test 5: Load Testing
echo -e "${BLUE}5. Running Load Test...${NC}"
LOAD_RESPONSE=$(curl -s "http://${ALB_DNS}/load?iterations=100000")
if echo "$LOAD_RESPONSE" | grep -q "Load test completed"; then
    echo -e "${GREEN}   ✅ Load test completed successfully${NC}"
else
    echo -e "${RED}   ❌ Load test failed${NC}"
    exit 1
fi

# Test 6: Security Groups
echo -e "${BLUE}6. Testing Security Configuration...${NC}"
VPC_ID=$(terraform output -raw vpc_id)
# Check if security groups exist and have proper rules
SG_COUNT=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'length(SecurityGroups[])' \
    --output text)

if [ "$SG_COUNT" -gt 0 ]; then
    echo -e "${GREEN}   ✅ Security groups configured ($SG_COUNT groups)${NC}"
else
    echo -e "${RED}   ❌ No security groups found${NC}"
    exit 1
fi

# Performance Test
echo -e "${BLUE}7. Performance Test (Response Time)...${NC}"
RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" "http://${ALB_DNS}/")
if (( $(echo "$RESPONSE_TIME < 2.0" | bc -l) )); then
    echo -e "${GREEN}   ✅ Response time: ${RESPONSE_TIME}s (< 2s)${NC}"
else
    echo -e "${YELLOW}   ⚠️  Response time: ${RESPONSE_TIME}s (> 2s)${NC}"
fi

echo -e "${GREEN}🎉 All tests passed! Infrastructure is working correctly.${NC}"
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "   Application URL: http://${ALB_DNS}"
echo -e "   Health Check: http://${ALB_DNS}/health"
echo -e "   Metrics: http://${ALB_DNS}/metrics"
echo -e "   Load Test: http://${ALB_DNS}/load"

# Make script executable
chmod +x scripts/validate.sh