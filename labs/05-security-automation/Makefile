# labs/05-security-automation/Makefile
# Automation commands for Security Automation

.PHONY: help install-trivy install-opa install-falco setup-rbac install-all configure-kubectl validate test

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)DevOps Studio - Lab 05: Security Automation$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

configure-kubectl: ## Configure kubectl (if not already done)
	@echo "$(BLUE)Checking kubectl configuration...$(NC)"
	@kubectl cluster-info > /dev/null 2>&1 || (echo "$(RED)Error: kubectl not configured. Run from Lab 02: make configure-kubectl$(NC)" && exit 1)
	@echo "$(GREEN)✅ kubectl is configured$(NC)"

install-trivy: ## Install Trivy (local installation)
	@echo "$(BLUE)Installing Trivy...$(NC)"
	@if command -v brew &> /dev/null; then \
		brew install trivy || echo "$(YELLOW)Trivy may already be installed$(NC)"; \
	elif command -v apt-get &> /dev/null; then \
		echo "$(YELLOW)Install Trivy manually: https://aquasecurity.github.io/trivy/latest/getting-started/installation/$(NC)"; \
	else \
		echo "$(YELLOW)Install Trivy manually: https://aquasecurity.github.io/trivy/latest/getting-started/installation/$(NC)"; \
	fi
	@if command -v trivy &> /dev/null; then \
		echo "$(GREEN)✅ Trivy installed: $$(trivy --version | head -n1)$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Trivy installation requires manual steps$(NC)"; \
	fi

install-opa: configure-kubectl ## Install OPA Gatekeeper
	@echo "$(BLUE)Installing OPA Gatekeeper...$(NC)"
	@helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts 2>/dev/null || true
	@helm repo update
	@helm upgrade --install gatekeeper gatekeeper/gatekeeper \
		--namespace gatekeeper-system \
		--create-namespace \
		--wait || echo "$(YELLOW)⚠️  Gatekeeper installation may take a few minutes$(NC)"
	@echo "$(BLUE)Waiting for Gatekeeper to be ready...$(NC)"
	@sleep 10
	@echo "$(BLUE)Installing OPA policies...$(NC)"
	@kubectl apply -f opa/policies/ || echo "$(YELLOW)⚠️  Some policies may already exist$(NC)"
	@kubectl apply -f opa/constraints/ || echo "$(YELLOW)⚠️  Some constraints may already exist$(NC)"
	@echo "$(GREEN)✅ OPA Gatekeeper installed and policies applied$(NC)"
	@echo "$(YELLOW)Check policies: kubectl get constrainttemplate$(NC)"
	@echo "$(YELLOW)Check constraints: kubectl get constraint$(NC)"

install-falco: configure-kubectl ## Install Falco runtime security
	@echo "$(BLUE)Installing Falco...$(NC)"
	@helm repo add falcosecurity https://falcosecurity.github.io/charts 2>/dev/null || true
	@helm repo update
	@helm upgrade --install falco falcosecurity/falco \
		--namespace falco \
		--create-namespace \
		--values falco/values.yaml \
		--wait || echo "$(YELLOW)⚠️  Falco installation may take a few minutes$(NC)"
	@echo "$(GREEN)✅ Falco installed$(NC)"
	@echo "$(YELLOW)View Falco events: kubectl logs -n falco -l app=falco -f$(NC)"

setup-rbac: configure-kubectl ## Set up RBAC roles and bindings
	@echo "$(BLUE)Setting up RBAC...$(NC)"
	@kubectl create namespace devops-studio 2>/dev/null || true
	@kubectl apply -f rbac/roles/
	@kubectl apply -f rbac/bindings/
	@echo "$(GREEN)✅ RBAC configured$(NC)"
	@echo "$(YELLOW)View roles: kubectl get roles -n devops-studio$(NC)"
	@echo "$(YELLOW)View bindings: kubectl get rolebindings -n devops-studio$(NC)"

install-all: configure-kubectl ## Install complete security stack
	@echo "$(BLUE)Installing complete security automation stack...$(NC)"
	@echo "$(YELLOW)This includes: Trivy, OPA Gatekeeper, Falco, and RBAC$(NC)"
	@echo "$(YELLOW)This will take 5-10 minutes...$(NC)"
	@$(MAKE) install-trivy
	@$(MAKE) install-opa
	@$(MAKE) install-falco
	@$(MAKE) setup-rbac
	@echo "$(GREEN)✅ Complete security stack installed!$(NC)"
	@echo ""
	@echo "$(BLUE)Security tools are now active:$(NC)"
	@echo "  Trivy:      Vulnerability scanning (local)"
	@echo "  OPA:        Policy enforcement (active)"
	@echo "  Falco:      Runtime security monitoring (active)"
	@echo "  RBAC:       Access control (configured)"

status: configure-kubectl ## Show status of all security components
	@echo "$(BLUE)Security Stack Status:$(NC)"
	@echo ""
	@echo "$(YELLOW)Trivy:$(NC)"
	@if command -v trivy &> /dev/null; then \
		trivy --version | head -n1; \
	else \
		echo "  Not installed"; \
	fi
	@echo ""
	@echo "$(YELLOW)OPA Gatekeeper:$(NC)"
	@kubectl get pods -n gatekeeper-system 2>/dev/null || echo "  Not installed"
	@kubectl get constrainttemplate 2>/dev/null | head -5 || echo "  No constraint templates"
	@echo ""
	@echo "$(YELLOW)Falco:$(NC)"
	@kubectl get pods -n falco 2>/dev/null || echo "  Not installed"
	@echo ""
	@echo "$(YELLOW)RBAC:$(NC)"
	@kubectl get roles -n devops-studio 2>/dev/null | head -5 || echo "  No roles configured"

validate: configure-kubectl ## Validate all security components
	@echo "$(BLUE)Validating security stack...$(NC)"
	@./scripts/validate.sh

test: configure-kubectl ## Test security tools
	@echo "$(BLUE)Running security tests...$(NC)"
	@./scripts/test-security.sh

scan-image: ## Scan a container image with Trivy
	@if [ -z "$(IMAGE)" ]; then \
		echo "$(RED)Error: IMAGE not specified. Usage: make scan-image IMAGE=nginx:latest$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Scanning image: $(IMAGE)$(NC)"
	@trivy image --severity HIGH,CRITICAL $(IMAGE)

scan-cluster: configure-kubectl ## Scan Kubernetes cluster with Trivy
	@echo "$(BLUE)Scanning Kubernetes cluster...$(NC)"
	@if command -v trivy &> /dev/null; then \
		trivy k8s cluster --format table; \
	else \
		echo "$(RED)Error: Trivy not installed. Run 'make install-trivy'$(NC)"; \
		exit 1; \
	fi

uninstall-all: configure-kubectl ## Uninstall all security components
	@echo "$(RED)⚠️  This will remove all security components$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		helm uninstall gatekeeper -n gatekeeper-system 2>/dev/null || true; \
		helm uninstall falco -n falco 2>/dev/null || true; \
		kubectl delete -f opa/policies/ --ignore-not-found=true; \
		kubectl delete -f opa/constraints/ --ignore-not-found=true; \
		kubectl delete -f rbac/roles/ --ignore-not-found=true; \
		kubectl delete -f rbac/bindings/ --ignore-not-found=true; \
		kubectl delete namespace gatekeeper-system --ignore-not-found=true; \
		kubectl delete namespace falco --ignore-not-found=true; \
		echo "$(GREEN)✅ Security stack removed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

.DEFAULT_GOAL := help

