# labs/04-observability-stack/Makefile
# Automation commands for Observability Stack

.PHONY: help install-prometheus install-grafana install-jaeger install-opensearch install-all configure-kubectl

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)DevOps Studio - Lab 04: Observability Stack$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

configure-kubectl: ## Configure kubectl (if not already done)
	@echo "$(BLUE)Checking kubectl configuration...$(NC)"
	@kubectl cluster-info > /dev/null 2>&1 || (echo "$(RED)Error: kubectl not configured. Run from Lab 02: make configure-kubectl$(NC)" && exit 1)
	@echo "$(GREEN)✅ kubectl is configured$(NC)"

install-prometheus: configure-kubectl ## Install Prometheus for metrics
	@echo "$(BLUE)Installing Prometheus...$(NC)"
	@helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
	@helm repo update
	@helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
		--namespace observability \
		--create-namespace \
		--values prometheus/values.yaml \
		--wait || echo "$(YELLOW)⚠️  Prometheus installation may take a few minutes$(NC)"
	@echo "$(BLUE)Applying alert rules...$(NC)"
	@kubectl apply -f prometheus/alert-rules.yaml || echo "$(YELLOW)⚠️  Alert rules may need to be applied after Prometheus is ready$(NC)"
	@echo "$(GREEN)✅ Prometheus installed$(NC)"
	@echo "$(YELLOW)Access Prometheus UI: kubectl port-forward -n observability svc/prometheus-kube-prometheus-prometheus 9090:9090$(NC)"

install-grafana: configure-kubectl ## Install Grafana for visualization
	@echo "$(BLUE)Installing Grafana...$(NC)"
	@helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
	@helm repo update
	@helm upgrade --install grafana grafana/grafana \
		--namespace observability \
		--values grafana/values.yaml \
		--wait || echo "$(YELLOW)⚠️  Grafana installation may take a few minutes$(NC)"
	@echo "$(GREEN)✅ Grafana installed$(NC)"
	@echo "$(YELLOW)Access Grafana UI: kubectl port-forward -n observability svc/grafana 3000:80$(NC)"
	@echo "$(YELLOW)Default credentials: admin / admin$(NC)"
	@echo "$(YELLOW)Data sources (Prometheus, OpenSearch, Jaeger) are pre-configured$(NC)"

install-jaeger: configure-kubectl ## Install Jaeger for distributed tracing
	@echo "$(BLUE)Installing Jaeger...$(NC)"
	@helm repo add jaegertracing https://jaegertracing.github.io/helm-charts 2>/dev/null || true
	@helm repo update
	@helm upgrade --install jaeger jaegertracing/jaeger \
		--namespace observability \
		--values jaeger/values.yaml \
		--wait || echo "$(YELLOW)⚠️  Jaeger installation may take a few minutes$(NC)"
	@echo "$(GREEN)✅ Jaeger installed$(NC)"
	@echo "$(YELLOW)Access Jaeger UI: kubectl port-forward -n observability svc/jaeger-query 16686:16686$(NC)"
	@echo "$(YELLOW)Note: Using memory storage (development). For production, configure Elasticsearch/Cassandra in jaeger/values.yaml$(NC)"

install-opensearch: configure-kubectl ## Install OpenSearch for log aggregation
	@echo "$(BLUE)Installing OpenSearch...$(NC)"
	@kubectl apply -f opensearch/manifests/opensearch-cluster.yaml
	@echo "$(YELLOW)Waiting for OpenSearch cluster to be ready (this may take 3-5 minutes)...$(NC)"
	@kubectl wait --for=condition=ready pod -l app=opensearch -n observability --timeout=300s || echo "$(YELLOW)⚠️  OpenSearch may still be starting$(NC)"
	@kubectl apply -f opensearch/manifests/opensearch-dashboards.yaml
	@kubectl apply -f opensearch/manifests/fluent-bit-config.yaml
	@echo "$(GREEN)✅ OpenSearch installed$(NC)"
	@echo "$(YELLOW)Access OpenSearch Dashboards: kubectl port-forward -n observability svc/opensearch-dashboards 5601:5601$(NC)"
	@echo "$(YELLOW)Default credentials: admin / admin (change in production!)$(NC)"

install-all: configure-kubectl ## Install complete observability stack
	@echo "$(BLUE)Installing complete observability stack...$(NC)"
	@echo "$(YELLOW)This includes: Prometheus, Grafana, Jaeger, and OpenSearch$(NC)"
	@echo "$(YELLOW)This will take 5-10 minutes...$(NC)"
	@$(MAKE) install-prometheus
	@$(MAKE) install-grafana
	@$(MAKE) install-jaeger
	@$(MAKE) install-opensearch
	@echo "$(GREEN)✅ Complete observability stack installed!$(NC)"
	@echo ""
	@echo "$(BLUE)Access URLs (after port-forwarding):$(NC)"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Grafana:    http://localhost:3000 (admin/admin)"
	@echo "  Jaeger:     http://localhost:16686"
	@echo "  OpenSearch: http://localhost:5601 (admin/admin)"

status: configure-kubectl ## Show status of all observability components
	@echo "$(BLUE)Observability Stack Status:$(NC)"
	@echo ""
	@echo "$(YELLOW)Prometheus:$(NC)"
	@kubectl get pods -n observability -l app.kubernetes.io/name=prometheus 2>/dev/null || echo "  Not installed"
	@echo ""
	@echo "$(YELLOW)Grafana:$(NC)"
	@kubectl get pods -n observability -l app.kubernetes.io/name=grafana 2>/dev/null || echo "  Not installed"
	@echo ""
	@echo "$(YELLOW)Jaeger:$(NC)"
	@kubectl get pods -n observability -l app.kubernetes.io/name=jaeger 2>/dev/null || echo "  Not installed"
	@echo ""
	@echo "$(YELLOW)OpenSearch:$(NC)"
	@kubectl get pods -n observability -l app=opensearch 2>/dev/null || echo "  Not installed"
	@echo ""
	@echo "$(YELLOW)Fluent Bit:$(NC)"
	@kubectl get pods -n observability -l app=fluent-bit 2>/dev/null || echo "  Not installed"

validate: configure-kubectl ## Validate all observability components
	@echo "$(BLUE)Validating observability stack...$(NC)"
	@./scripts/validate.sh

uninstall-all: configure-kubectl ## Uninstall all observability components
	@echo "$(RED)⚠️  This will remove all observability components$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		helm uninstall prometheus -n observability 2>/dev/null || true; \
		helm uninstall grafana -n observability 2>/dev/null || true; \
		helm uninstall jaeger -n observability 2>/dev/null || true; \
		kubectl delete -f opensearch/manifests/ --ignore-not-found=true; \
		kubectl delete namespace observability --ignore-not-found=true; \
		echo "$(GREEN)✅ Observability stack removed$(NC)"; \
	else \
		echo "$(YELLOW)Operation cancelled$(NC)"; \
	fi

.DEFAULT_GOAL := help

