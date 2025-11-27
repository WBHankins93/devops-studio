# labs/07-serverless-operations/Makefile
# Automation commands for Serverless Operations

.PHONY: help init plan apply destroy validate test test-api test-lambda clean

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)DevOps Studio - Lab 07: Serverless Operations$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-aws: ## Check AWS credentials
	@echo "$(BLUE)Checking AWS credentials...$(NC)"
	@aws sts get-caller-identity > /dev/null 2>&1 || (echo "$(RED)Error: AWS credentials not configured. Run 'aws configure'$(NC)" && exit 1)
	@echo "$(GREEN)✅ AWS credentials configured$(NC)"

init: check-aws ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	@terraform init
	@echo "$(GREEN)✅ Terraform initialized$(NC)"

plan: check-aws ## Plan Terraform changes
	@echo "$(BLUE)Planning Terraform changes...$(NC)"
	@terraform plan

apply: check-aws ## Apply Terraform changes
	@echo "$(BLUE)Applying Terraform changes...$(NC)"
	@echo "$(YELLOW)This will create Lambda functions, API Gateway, DynamoDB, EventBridge, and Step Functions$(NC)"
	@terraform apply

deploy: apply ## Alias for apply

destroy: check-aws ## Destroy all resources
	@echo "$(RED)⚠️  This will destroy ALL serverless resources$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform destroy; \
		echo "$(GREEN)✅ Resources destroyed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

validate: check-aws ## Validate serverless stack
	@echo "$(BLUE)Validating serverless stack...$(NC)"
	@./scripts/validate.sh

test-api: check-aws ## Test API Gateway endpoint
	@echo "$(BLUE)Testing API Gateway...$(NC)"
	@./scripts/test-api.sh

test-lambda: check-aws ## Test Lambda functions
	@echo "$(BLUE)Testing Lambda functions...$(NC)"
	@echo "$(YELLOW)Testing hello-world function...$(NC)"
	@aws lambda invoke \
		--function-name devops-studio-dev-hello-world \
		--payload '{"name":"Developer","message":"Hello"}' \
		response.json > /dev/null && \
		cat response.json | jq '.' && \
		rm -f response.json || echo "$(RED)Error testing function$(NC)"

invoke-hello: check-aws ## Invoke hello-world Lambda
	@aws lambda invoke \
		--function-name devops-studio-dev-hello-world \
		--payload '{"name":"Developer","message":"Hello"}' \
		response.json && \
		cat response.json | jq '.' && \
		rm -f response.json

invoke-api-handler: check-aws ## Invoke api-handler Lambda
	@aws lambda invoke \
		--function-name devops-studio-dev-api-handler \
		--payload '{"httpMethod":"GET","path":"/test"}' \
		response.json && \
		cat response.json | jq '.' && \
		rm -f response.json

invoke-event-processor: check-aws ## Invoke event-processor Lambda
	@aws lambda invoke \
		--function-name devops-studio-dev-event-processor \
		--payload '{"source":"test","detail-type":"Test Event","detail":{"message":"Hello"}}' \
		response.json && \
		cat response.json | jq '.' && \
		rm -f response.json

logs-hello: check-aws ## View hello-world logs
	@echo "$(BLUE)Viewing hello-world logs...$(NC)"
	@aws logs tail /aws/lambda/devops-studio-dev-hello-world --follow

logs-api: check-aws ## View api-handler logs
	@echo "$(BLUE)Viewing api-handler logs...$(NC)"
	@aws logs tail /aws/lambda/devops-studio-dev-api-handler --follow

logs-events: check-aws ## View event-processor logs
	@echo "$(BLUE)Viewing event-processor logs...$(NC)"
	@aws logs tail /aws/lambda/devops-studio-dev-event-processor --follow

outputs: ## Show Terraform outputs
	@echo "$(BLUE)Terraform Outputs:$(NC)"
	@terraform output

clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	@rm -f lambda/*/function.zip
	@rm -f response.json
	@rm -f *.tfplan
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

.DEFAULT_GOAL := help

