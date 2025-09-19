# labs/01-terraform-foundations/Makefile
# Automation commands for Terraform infrastructure management

.PHONY: help init plan apply destroy test validate ssh logs output clean setup-backend

# Default environment
ENV ?= dev
TERRAFORM_VAR_FILE = environments/$(ENV).tfvars

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)DevOps Studio - Lab 01: Terraform Foundations$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup-backend: ## Initialize remote state backend (S3 + DynamoDB)
	@echo "$(BLUE)Setting up Terraform backend...$(NC)"
	./scripts/setup-backend.sh

init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	terraform init

plan: init ## Create execution plan
	@echo "$(BLUE)Creating Terraform plan for $(ENV) environment...$(NC)"
	terraform plan -var-file="$(TERRAFORM_VAR_FILE)" -out=tfplan

apply: ## Apply Terraform changes
	@echo "$(BLUE)Applying Terraform changes for $(ENV) environment...$(NC)"
	@if [ ! -f tfplan ]; then \
		echo "$(YELLOW)No plan found, creating one first...$(NC)"; \
		make plan ENV=$(ENV); \
	fi
	terraform apply tfplan
	@rm -f tfplan
	@echo "$(GREEN)✅ Infrastructure deployed successfully!$(NC)"
	@echo "$(YELLOW)Application URL: http://$$(terraform output -raw load_balancer_dns)$(NC)"

destroy: ## Destroy all infrastructure
	@echo "$(RED)⚠️  This will destroy all infrastructure in $(ENV) environment$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform destroy -var-file="$(TERRAFORM_VAR_FILE)" -auto-approve; \
		echo "$(RED)🗑️  Infrastructure destroyed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

test: ## Test the deployed infrastructure
	@echo "$(BLUE)Testing deployed infrastructure...$(NC)"
	./scripts/validate.sh

validate: ## Validate Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration...$(NC)"
	terraform validate
	terraform fmt -check=true -recursive
	@echo "$(GREEN)✅ Configuration is valid$(NC)"

output: ## Show Terraform outputs
	@echo "$(BLUE)Terraform outputs:$(NC)"
	terraform output

ssh: ## SSH to a random instance (requires key pair)
	@echo "$(BLUE)Connecting to application instance...$(NC)"
	@INSTANCE_ID=$$(aws ec2 describe-instances \
		--filters "Name=tag:Project,Values=$$(terraform output -raw project_name)" \
		          "Name=tag:Environment,Values=$$(terraform output -raw environment)" \
		          "Name=instance-state-name,Values=running" \
		--query 'Reservations[0].Instances[0].InstanceId' \
		--output text); \
	if [ "$$INSTANCE_ID" != "None" ]; then \
		aws ssm start-session --target $$INSTANCE_ID; \
	else \
		echo "$(RED)No running instances found$(NC)"; \
	fi

logs: ## View application logs
	@echo "$(BLUE)Fetching application logs...$(NC)"
	@LOG_GROUP="/aws/ec2/$(terraform output -raw project_name)-$(terraform output -raw environment)"; \
	aws logs describe-log-streams \
		--log-group-name "$LOG_GROUP" \
		--order-by LastEventTime \
		--descending \
		--max-items 1 \
		--query 'logStreams[0].logStreamName' \
		--output text | \
	xargs -I {} aws logs get-log-events \
		--log-group-name "$LOG_GROUP" \
		--log-stream-name {} \
		--query 'events[*].[timestamp,message]' \
		--output table

clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	rm -f tfplan
	rm -f terraform.tfstate.backup
	rm -rf .terraform.lock.hcl
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

format: ## Format Terraform code
	@echo "$(BLUE)Formatting Terraform code...$(NC)"
	terraform fmt -recursive
	@echo "$(GREEN)✅ Code formatted$(NC)"

docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	terraform-docs markdown table --output-file TERRAFORM.md .
	@echo "$(GREEN)✅ Documentation generated$(NC)"

cost: ## Estimate infrastructure costs (requires infracost)
	@echo "$(BLUE)Estimating infrastructure costs...$(NC)"
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path . --terraform-var-file $(TERRAFORM_VAR_FILE); \
	else \
		echo "$(YELLOW)infracost not installed. Install from: https://www.infracost.io/docs/$(NC)"; \
	fi

security: ## Run security scan (requires tfsec)
	@echo "$(BLUE)Running security scan...$(NC)"
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "$(YELLOW)tfsec not installed. Install from: https://github.com/aquasecurity/tfsec$(NC)"; \
	fi

# Multi-environment commands
plan-all: ## Plan for all environments
	@for env in dev staging prod; do \
		echo "$(BLUE)Planning for $env environment...$(NC)"; \
		make plan ENV=$env; \
	done

validate-all: ## Validate all environment configurations
	@for env in dev staging prod; do \
		echo "$(BLUE)Validating $env environment...$(NC)"; \
		terraform validate -var-file="environments/$env.tfvars"; \
	done

# Development helpers
watch: ## Watch for changes and auto-format
	@echo "$(BLUE)Watching for file changes...$(NC)"
	@if command -v fswatch >/dev/null 2>&1; then \
		fswatch -o . | xargs -n1 -I{} make format; \
	else \
		echo "$(YELLOW)fswatch not installed. Install with: brew install fswatch$(NC)"; \
	fi