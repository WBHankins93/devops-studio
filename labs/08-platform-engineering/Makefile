# labs/08-platform-engineering/Makefile
# Automation commands for Platform Engineering

.PHONY: help init plan apply destroy validate check-aws

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)DevOps Studio - Lab 08: Platform Engineering$(NC)"
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
	@echo "$(YELLOW)This will create platform infrastructure (S3, DynamoDB, IAM, etc.)$(NC)"
	@terraform apply

deploy: apply ## Alias for apply

destroy: check-aws ## Destroy all resources
	@echo "$(RED)⚠️  This will destroy ALL platform infrastructure$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform destroy; \
		echo "$(GREEN)✅ Resources destroyed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

validate: check-aws ## Validate platform infrastructure
	@echo "$(BLUE)Validating platform infrastructure...$(NC)"
	@./scripts/validate.sh

outputs: ## Show Terraform outputs
	@echo "$(BLUE)Terraform Outputs:$(NC)"
	@terraform output

clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	@rm -f *.tfplan
	@rm -f .terraform.lock.hcl
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

.DEFAULT_GOAL := help

