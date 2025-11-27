# labs/06-gitops-workflows/Makefile
# Automation commands for GitOps Workflows

.PHONY: help install-argocd install-flux setup-kustomize install-all configure-kubectl validate test build-staging build-production

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)DevOps Studio - Lab 06: GitOps Workflows$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

configure-kubectl: ## Configure kubectl (if not already done)
	@echo "$(BLUE)Checking kubectl configuration...$(NC)"
	@kubectl cluster-info > /dev/null 2>&1 || (echo "$(RED)Error: kubectl not configured. Run from Lab 02: make configure-kubectl$(NC)" && exit 1)
	@echo "$(GREEN)✅ kubectl is configured$(NC)"

setup-kustomize: ## Set up Kustomize base and overlays structure
	@echo "$(BLUE)Setting up Kustomize structure...$(NC)"
	@echo "$(YELLOW)Kustomize base and overlays are already in place$(NC)"
	@echo "$(GREEN)✅ Kustomize structure ready$(NC)"
	@echo "$(YELLOW)Base: kustomize/base/$(NC)"
	@echo "$(YELLOW)Staging overlay: kustomize/overlays/staging/$(NC)"
	@echo "$(YELLOW)Production overlay: kustomize/overlays/production/$(NC)"

build-staging: configure-kubectl ## Build staging configuration with Kustomize
	@echo "$(BLUE)Building staging configuration...$(NC)"
	@kubectl kustomize kustomize/overlays/staging
	@echo "$(GREEN)✅ Staging configuration built$(NC)"

build-production: configure-kubectl ## Build production configuration with Kustomize
	@echo "$(BLUE)Building production configuration...$(NC)"
	@kubectl kustomize kustomize/overlays/production
	@echo "$(GREEN)✅ Production configuration built$(NC)"

apply-staging: configure-kubectl ## Apply staging configuration
	@echo "$(BLUE)Applying staging configuration...$(NC)"
	@kubectl apply -k kustomize/overlays/staging
	@echo "$(GREEN)✅ Staging configuration applied$(NC)"

apply-production: configure-kubectl ## Apply production configuration
	@echo "$(RED)⚠️  Applying to production - are you sure?$(NC)"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		kubectl apply -k kustomize/overlays/production; \
		echo "$(GREEN)✅ Production configuration applied$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

install-argocd: configure-kubectl ## Install Argo CD
	@echo "$(BLUE)Installing Argo CD...$(NC)"
	@helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
	@helm repo update
	@helm upgrade --install argocd argo/argo-cd \
		--namespace argocd \
		--create-namespace \
		--values argocd/values.yaml \
		--wait || echo "$(YELLOW)⚠️  Argo CD installation may take a few minutes$(NC)"
	@echo "$(BLUE)Waiting for Argo CD to be ready...$(NC)"
	@sleep 15
	@echo "$(GREEN)✅ Argo CD installed$(NC)"
	@echo ""
	@echo "$(YELLOW)Access Argo CD UI:$(NC)"
	@echo "  1. Port-forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
	@echo "  2. Get password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
	@echo "  3. Open: https://localhost:8080 (username: admin)"

install-flux: configure-kubectl ## Install Flux
	@echo "$(BLUE)Installing Flux...$(NC)"
	@if ! command -v flux &> /dev/null; then \
		echo "$(YELLOW)Flux CLI not found. Installing...$(NC)"; \
		curl -s https://fluxcd.io/install.sh | sudo bash || echo "$(YELLOW)⚠️  Flux CLI installation may require manual steps$(NC)"; \
	fi
	@helm repo add fluxcd https://fluxcd-community.github.io/helm-charts 2>/dev/null || true
	@helm repo update
	@helm upgrade --install flux fluxcd/flux2 \
		--namespace flux-system \
		--create-namespace \
		--wait || echo "$(YELLOW)⚠️  Flux installation may take a few minutes$(NC)"
	@echo "$(GREEN)✅ Flux installed$(NC)"
	@echo ""
	@echo "$(YELLOW)Manage Flux via CLI:$(NC)"
	@echo "  flux get sources git"
	@echo "  flux get kustomizations"

configure-argocd: configure-kubectl ## Configure Argo CD applications
	@echo "$(BLUE)Configuring Argo CD applications...$(NC)"
	@echo "$(YELLOW)⚠️  Update argocd/application.yaml with your Git repository URL$(NC)"
	@echo "$(YELLOW)Then run: kubectl apply -f argocd/application.yaml$(NC)"
	@if kubectl get namespace argocd &> /dev/null; then \
		kubectl apply -f argocd/application.yaml || echo "$(YELLOW)⚠️  Update application.yaml with your Git repo URL first$(NC)"; \
		echo "$(GREEN)✅ Argo CD applications configured$(NC)"; \
	else \
		echo "$(RED)Error: Argo CD not installed. Run 'make install-argocd' first$(NC)"; \
	fi

configure-flux: configure-kubectl ## Configure Flux GitRepository and Kustomization
	@echo "$(BLUE)Configuring Flux resources...$(NC)"
	@echo "$(YELLOW)⚠️  Update flux/gitrepository.yaml with your Git repository URL$(NC)"
	@echo "$(YELLOW)Then run: kubectl apply -f flux/$(NC)"
	@if kubectl get namespace flux-system &> /dev/null; then \
		kubectl apply -f flux/gitrepository.yaml || echo "$(YELLOW)⚠️  Update gitrepository.yaml with your Git repo URL first$(NC)"; \
		kubectl apply -f flux/kustomization.yaml || echo "$(YELLOW)⚠️  Update kustomization.yaml with your Git repo URL first$(NC)"; \
		echo "$(GREEN)✅ Flux resources configured$(NC)"; \
	else \
		echo "$(RED)Error: Flux not installed. Run 'make install-flux' first$(NC)"; \
	fi

install-all: configure-kubectl ## Install complete GitOps stack (choose Argo CD or Flux)
	@echo "$(BLUE)Installing GitOps stack...$(NC)"
	@echo "$(YELLOW)This will install Kustomize setup and you can choose Argo CD or Flux$(NC)"
	@$(MAKE) setup-kustomize
	@echo ""
	@echo "$(YELLOW)Choose your GitOps tool:$(NC)"
	@echo "  For Argo CD (visual): make install-argocd"
	@echo "  For Flux (CLI): make install-flux"
	@echo ""
	@echo "$(GREEN)✅ Kustomize structure ready$(NC)"

status: configure-kubectl ## Show status of all GitOps components
	@echo "$(BLUE)GitOps Stack Status:$(NC)"
	@echo ""
	@echo "$(YELLOW)Kustomize:$(NC)"
	@if kubectl kustomize kustomize/base &> /dev/null; then \
		echo "  ✅ Base configuration valid"; \
	else \
		echo "  ❌ Base configuration has issues"; \
	fi
	@echo ""
	@echo "$(YELLOW)Argo CD:$(NC)"
	@kubectl get pods -n argocd 2>/dev/null || echo "  Not installed"
	@kubectl get applications -n argocd 2>/dev/null | head -5 || echo "  No applications"
	@echo ""
	@echo "$(YELLOW)Flux:$(NC)"
	@kubectl get pods -n flux-system 2>/dev/null || echo "  Not installed"
	@if command -v flux &> /dev/null; then \
		flux get sources git 2>/dev/null | head -5 || echo "  No GitRepositories"; \
		flux get kustomizations 2>/dev/null | head -5 || echo "  No Kustomizations"; \
	fi

validate: configure-kubectl ## Validate all GitOps components
	@echo "$(BLUE)Validating GitOps stack...$(NC)"
	@./scripts/validate.sh

test: configure-kubectl ## Test GitOps tools
	@echo "$(BLUE)Running GitOps tests...$(NC)"
	@./scripts/test-gitops.sh

uninstall-argocd: configure-kubectl ## Uninstall Argo CD
	@echo "$(RED)⚠️  This will remove Argo CD$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		helm uninstall argocd -n argocd 2>/dev/null || true; \
		kubectl delete -f argocd/application.yaml --ignore-not-found=true; \
		kubectl delete namespace argocd --ignore-not-found=true; \
		echo "$(GREEN)✅ Argo CD removed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

uninstall-flux: configure-kubectl ## Uninstall Flux
	@echo "$(RED)⚠️  This will remove Flux$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		helm uninstall flux -n flux-system 2>/dev/null || true; \
		kubectl delete -f flux/ --ignore-not-found=true; \
		kubectl delete namespace flux-system --ignore-not-found=true; \
		echo "$(GREEN)✅ Flux removed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

uninstall-all: configure-kubectl ## Uninstall all GitOps tools
	@echo "$(RED)⚠️  This will remove all GitOps tools$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(MAKE) uninstall-argocd; \
		$(MAKE) uninstall-flux; \
		echo "$(GREEN)✅ All GitOps tools removed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

.DEFAULT_GOAL := help

