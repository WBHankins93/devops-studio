.PHONY: help test build deploy validate clean setup

# Configuration
IMAGE_NAME ?= devops-studio-app
IMAGE_TAG ?= latest
ENVIRONMENT ?= staging
NAMESPACE ?= devops-studio
AWS_REGION ?= us-west-2
AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")

# Colors
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(GREEN)DevOps Studio - Lab 03: CI/CD Pipelines$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

setup: ## Install dependencies and setup environment
	@echo "$(GREEN)Setting up environment...$(NC)"
	@cd app && npm ci
	@chmod +x scripts/*.sh
	@echo "$(GREEN)Setup complete!$(NC)"

test: ## Run all tests
	@echo "$(GREEN)Running tests...$(NC)"
	@./scripts/test.sh

test-unit: ## Run unit tests only
	@echo "$(GREEN)Running unit tests...$(NC)"
	@cd app && npm run test:unit

test-integration: ## Run integration tests only
	@echo "$(GREEN)Running integration tests...$(NC)"
	@cd app && npm run test:integration

build: ## Build Docker image
	@echo "$(GREEN)Building Docker image...$(NC)"
	@./scripts/build.sh

build-push: ## Build and push Docker image to ECR
	@echo "$(GREEN)Building and pushing Docker image...$(NC)"
	@if [ -z "$(AWS_ACCOUNT_ID)" ]; then \
		echo "$(RED)Error: AWS_ACCOUNT_ID not set. Please configure AWS credentials.$(NC)"; \
		exit 1; \
	fi
	@DOCKER_REGISTRY=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com \
	PUSH_IMAGE=true \
	IMAGE_TAG=$(IMAGE_TAG) \
	./scripts/build.sh

deploy: ## Deploy to Kubernetes
	@echo "$(GREEN)Deploying to Kubernetes...$(NC)"
	@./scripts/deploy.sh

deploy-staging: ## Deploy to staging environment
	@echo "$(GREEN)Deploying to staging...$(NC)"
	@ENVIRONMENT=staging IMAGE_TAG=$(IMAGE_TAG) ./scripts/deploy.sh

deploy-production: ## Deploy to production environment
	@echo "$(YELLOW)WARNING: Deploying to production!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		ENVIRONMENT=production IMAGE_TAG=$(IMAGE_TAG) ./scripts/deploy.sh; \
	else \
		echo "$(YELLOW)Deployment cancelled.$(NC)"; \
	fi

validate: ## Validate deployed application
	@echo "$(GREEN)Validating deployment...$(NC)"
	@./scripts/validate.sh

clean: ## Clean up local resources
	@echo "$(GREEN)Cleaning up...$(NC)"
	@docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-k8s: ## Remove Kubernetes resources
	@echo "$(YELLOW)Removing Kubernetes resources...$(NC)"
	@kubectl delete -f k8s/ --ignore-not-found=true
	@echo "$(GREEN)Kubernetes resources removed!$(NC)"

lint: ## Run linting checks
	@echo "$(GREEN)Running linting checks...$(NC)"
	@cd app && npm run lint 2>/dev/null || echo "$(YELLOW)Linting not configured$(NC)"

security-scan: ## Run security scan on Docker image
	@echo "$(GREEN)Running security scan...$(NC)"
	@if ! command -v trivy &> /dev/null; then \
		echo "$(YELLOW)Trivy not installed. Installing...$(NC)"; \
		docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
			aquasec/trivy:latest image $(IMAGE_NAME):$(IMAGE_TAG); \
	else \
		trivy image $(IMAGE_NAME):$(IMAGE_TAG); \
	fi

all: setup test build ## Run setup, tests, and build

.DEFAULT_GOAL := help

