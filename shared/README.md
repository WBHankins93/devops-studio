# Shared Resources

Reusable components and configurations shared across DevOps Studio labs.

## Structure

```
shared/
├── terraform-modules/    # Reusable Terraform modules
├── helm-charts/          # Custom Helm charts
├── scripts/              # Shared automation scripts
└── configs/              # Configuration templates
```

## Terraform Modules

Reusable Terraform modules that can be used across multiple labs.

### Usage

```hcl
module "example" {
  source = "../../shared/terraform-modules/example"
  
  # Module variables
}
```

## Helm Charts

Custom Helm charts for Kubernetes deployments.

### Usage

```bash
helm install my-release ../../shared/helm-charts/example
```

## Scripts

Shared automation scripts for common tasks.

### Usage

```bash
./shared/scripts/example.sh
```

## Configs

Configuration templates and examples.

### Usage

Copy and customize configuration files as needed.

---

**Note**: This directory is a work in progress. More shared resources will be added as labs are completed.

