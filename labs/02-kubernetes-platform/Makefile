# labs/02-kubernetes-platform/Makefile
# Automation commands for EKS cluster management

.PHONY: help init plan apply destroy test validate configure-kubectl deploy-app cluster-info verify-cluster install-helm-charts deploy-helm-chart

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
	@echo "$(BLUE)DevOps Studio - Lab 02: Kubernetes Platform$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup-backend: ## Initialize remote state backend (S3 + DynamoDB)
	@echo "$(BLUE)Setting up Terraform backend...$(NC)"
	./scripts/setup-backend.sh

init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	terraform init

plan: init ## Create execution plan
	@echo "$(BLUE)Creating Terraform plan for $(ENV) environment...$(NC)"
	terraform plan -var-file="$(TERRAFORM_VAR_FILE)" -out=tfplan

apply: ## Apply Terraform changes (deploy EKS cluster)
	@echo "$(BLUE)Applying Terraform changes for $(ENV) environment...$(NC)"
	@if [ ! -f tfplan ]; then \
		echo "$(YELLOW)No plan found, creating one first...$(NC)"; \
		make plan ENV=$(ENV); \
	fi
	terraform apply tfplan
	@rm -f tfplan
	@echo "$(GREEN)✅ EKS cluster deployed successfully!$(NC)"
	@echo "$(YELLOW)Cluster Name: $$(terraform output -raw cluster_name)$(NC)"
	@echo "$(YELLOW)Next: Run 'make configure-kubectl' to configure kubectl$(NC)"

destroy: ## Destroy all infrastructure
	@echo "$(RED)⚠️  This will destroy the EKS cluster and all resources in $(ENV) environment$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		terraform destroy -var-file="$(TERRAFORM_VAR_FILE)" -auto-approve; \
		echo "$(RED)🗑️  Infrastructure destroyed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

configure-kubectl: ## Configure kubectl to connect to the cluster
	@echo "$(BLUE)Configuring kubectl...$(NC)"
	./scripts/configure-kubectl.sh

verify-cluster: configure-kubectl ## Verify cluster is accessible
	@echo "$(BLUE)Verifying cluster access...$(NC)"
	@kubectl cluster-info
	@kubectl get nodes
	@echo "$(GREEN)✅ Cluster is accessible$(NC)"

install-helm-charts: configure-kubectl ## Install Helm charts (NGINX Ingress, Metrics Server)
	@echo "$(BLUE)Installing Helm charts...$(NC)"
	@echo "$(BLUE)Installing NGINX Ingress Controller...$(NC)"
	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
	@helm repo update
	@helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
		--namespace ingress-nginx \
		--create-namespace \
		--set controller.service.type=LoadBalancer \
		--wait || echo "$(YELLOW)⚠️  Ingress controller installation may take a few minutes$(NC)"
	@echo "$(BLUE)Installing Metrics Server...$(NC)"
	@helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ 2>/dev/null || true
	@helm repo update
	@helm upgrade --install metrics-server metrics-server/metrics-server \
		--namespace kube-system \
		--set args="{--kubelet-insecure-tls}" \
		--wait || echo "$(YELLOW)⚠️  Metrics server installation may take a few minutes$(NC)"
	@echo "$(GREEN)✅ Helm charts installed$(NC)"

deploy-helm-chart: configure-kubectl ## Deploy sample application using Helm chart
	@echo "$(BLUE)Deploying sample application with Helm...$(NC)"
	@helm upgrade --install sample-app ./helm-charts/sample-app \
		--namespace devops-studio \
		--create-namespace \
		--wait || echo "$(YELLOW)⚠️  Deployment may take a few minutes$(NC)"
	@echo "$(GREEN)✅ Sample application deployed with Helm$(NC)"
	@kubectl get pods -n devops-studio
	@echo "$(YELLOW)To enable Ingress, run: helm upgrade sample-app ./helm-charts/sample-app --set ingress.enabled=true$(NC)"

deploy-app: configure-kubectl ## Deploy sample application
	@echo "$(BLUE)Deploying sample application...$(NC)"
	@kubectl apply -f manifests/namespace.yaml
	@kubectl apply -f manifests/deployment.yaml
	@kubectl apply -f manifests/service.yaml
	@echo "$(GREEN)✅ Sample application deployed$(NC)"
	@echo "$(BLUE)Waiting for pods to be ready...$(NC)"
	@kubectl wait --for=condition=available --timeout=300s deployment/sample-app -n devops-studio || true
	@kubectl get pods -n devops-studio
	@echo "$(YELLOW)To expose via Ingress, run: kubectl apply -f manifests/ingress.yaml$(NC)"

deploy-ingress: configure-kubectl ## Deploy Ingress configuration
	@echo "$(BLUE)Deploying Ingress...$(NC)"
	@kubectl apply -f manifests/ingress.yaml
	@echo "$(GREEN)✅ Ingress deployed$(NC)"
	@echo "$(BLUE)Getting Ingress Load Balancer address...$(NC)"
	@echo "$(YELLOW)Waiting for Load Balancer (this may take 2-3 minutes)...$(NC)"
	@timeout 180 bash -c 'until kubectl get ingress -n devops-studio sample-app-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null; do sleep 5; done' || echo "$(YELLOW)Load Balancer may still be provisioning. Check with: kubectl get ingress -n devops-studio$(NC)"

test: validate ## Test the deployed cluster and applications
	@echo "$(BLUE)Running comprehensive tests...$(NC)"
	./scripts/validate.sh

validate: configure-kubectl ## Validate cluster configuration
	@echo "$(BLUE)Validating cluster...$(NC)"
	@terraform validate
	@terraform fmt -check=true -recursive
	@./scripts/validate.sh

output: ## Show Terraform outputs
	@echo "$(BLUE)Terraform outputs:$(NC)"
	@terraform output

cluster-info: configure-kubectl ## Show cluster information
	@echo "$(BLUE)Cluster Information:$(NC)"
	@kubectl cluster-info
	@echo ""
	@echo "$(BLUE)Nodes:$(NC)"
	@kubectl get nodes -o wide
	@echo ""
	@echo "$(BLUE)Namespaces:$(NC)"
	@kubectl get namespaces
	@echo ""
	@echo "$(BLUE)All Pods:$(NC)"
	@kubectl get pods --all-namespaces

logs: configure-kubectl ## View application logs
	@echo "$(BLUE)Fetching application logs...$(NC)"
	@kubectl logs -n devops-studio -l app=sample-app --tail=50 || echo "$(YELLOW)No sample-app pods found$(NC)"

clean: ## Clean up temporary files
	@echo "$(BLUE)Cleaning up temporary files...$(NC)"
	@rm -f tfplan
	@rm -f terraform.tfstate.backup
	@rm -rf .terraform.lock.hcl
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

format: ## Format Terraform code
	@echo "$(BLUE)Formatting Terraform code...$(NC)"
	@terraform fmt -recursive
	@echo "$(GREEN)✅ Code formatted$(NC)"

# Multi-environment commands
plan-all: ## Plan for all environments
	@for env in dev staging prod; do \
		echo "$(BLUE)Planning for $env environment...$(NC)"; \
		make plan ENV=$$env; \
	done

validate-all: ## Validate all environment configurations
	@for env in dev staging prod; do \
		echo "$(BLUE)Validating $env environment...$(NC)"; \
		terraform validate -var-file="environments/$$env.tfvars"; \
	done

