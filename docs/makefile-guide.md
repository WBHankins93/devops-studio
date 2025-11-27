# Makefile Guide
*Understanding and Using Makefiles in DevOps Studio*

> **Navigation**: [DevOps Studio](../README.md) > [Documentation](README.md) > Makefile Guide

---

## What is a Makefile?

A **Makefile** is a build automation tool that uses a simple text file to define commands and their relationships. It's been a standard in software development for decades and is particularly useful for:

- **Automating repetitive tasks** (deploy, test, clean)
- **Standardizing commands** across different environments
- **Documenting workflows** in a single place
- **Reducing errors** by using predefined commands

### Why Use Makefiles?

Instead of remembering complex commands like:
```bash
terraform init && terraform plan -var-file="environments/dev.tfvars" && terraform apply
```

You can simply run:
```bash
make apply ENV=dev
```

---

## How to Use Makefiles

### Basic Usage

Makefiles are used with the `make` command:

```bash
make <target>
```

Where `<target>` is the name of a command defined in the Makefile.

### Viewing Available Commands

Every lab includes a `Makefile` with a help command:

```bash
make help
```

This displays all available commands with descriptions.

### Example Output

```
DevOps Studio - Lab 02: Kubernetes Platform
Available commands:
  init              Initialize Terraform
  plan              Create execution plan
  apply             Apply Terraform changes (deploy EKS cluster)
  configure-kubectl Configure kubectl to connect to the cluster
  deploy-app        Deploy sample application
  ...
```

---

## Common Makefile Commands

### Lab-Specific Commands

Each lab has its own Makefile with commands tailored to that lab's needs. Common patterns include:

#### Infrastructure Labs (Terraform)

```bash
make init          # Initialize Terraform
make plan          # Preview changes
make apply         # Deploy infrastructure
make destroy       # Remove infrastructure
make validate      # Validate configuration
```

#### Kubernetes Labs

```bash
make configure-kubectl    # Set up kubectl
make deploy-app          # Deploy application
make install-helm-charts # Install Helm charts
make cluster-info        # Show cluster details
```

#### CI/CD Labs

```bash
make setup      # Install dependencies
make test       # Run tests
make build      # Build application
make deploy     # Deploy to environment
```

---

## Understanding Makefile Syntax

### Basic Structure

```makefile
target: ## Description of what this does
    command1
    command2
```

**Example**:
```makefile
deploy: ## Deploy the application
    kubectl apply -f manifests/
    kubectl rollout status deployment/app
```

### Variables

Makefiles can use variables for configuration:

```makefile
ENV ?= dev
IMAGE_TAG ?= latest

deploy:
    helm upgrade --install app ./chart --set image.tag=$(IMAGE_TAG)
```

**Usage**:
```bash
make deploy ENV=staging IMAGE_TAG=v1.2.3
```

### Dependencies

Commands can depend on other commands:

```makefile
deploy: validate ## Deploy (runs validate first)
    kubectl apply -f manifests/

validate: ## Validate configuration
    terraform validate
```

When you run `make deploy`, it automatically runs `validate` first.

---

## Installation

### macOS

```bash
# Using Homebrew
brew install make

# Verify installation
make --version
```

### Linux

```bash
# Most distributions include make by default
make --version

# If not installed:
sudo apt-get install build-essential  # Ubuntu/Debian
sudo yum install make                 # CentOS/RHEL
```

### Windows

**Option 1: WSL (Windows Subsystem for Linux)**
```bash
# Install WSL, then use Linux commands above
```

**Option 2: Chocolatey**
```bash
choco install make
```

**Option 3: Git Bash**
- Git for Windows includes make
- Use Git Bash terminal

---

## Tips and Best Practices

### 1. Always Check Available Commands

```bash
make help
```

This shows all available commands with descriptions.

### 2. Use Environment Variables

Many Makefiles support environment-specific configurations:

```bash
make apply ENV=dev      # Development environment
make apply ENV=staging  # Staging environment
make apply ENV=prod     # Production environment
```

### 3. Read the Makefile

If you're unsure what a command does, check the Makefile:

```bash
cat Makefile
# or
less Makefile
```

### 4. Combine Commands

You can run multiple commands in sequence:

```bash
make init plan apply
```

### 5. Use Tab Completion

Most shells support tab completion for make targets:

```bash
make <TAB><TAB>  # Shows available commands
```

---

## Troubleshooting

### "make: command not found"

**Solution**: Install make (see Installation section above)

### "No rule to make target 'xyz'"

**Possible causes**:
- Typo in command name
- Wrong directory (Makefile not in current directory)
- Command doesn't exist in this lab's Makefile

**Solution**:
```bash
# Check you're in the right directory
pwd

# Check available commands
make help

# Verify Makefile exists
ls -la Makefile
```

### "Permission denied"

**Solution**: Makefiles don't need execute permissions, but scripts they call might:

```bash
chmod +x scripts/*.sh
```

### Command Fails

**Solution**: Check the error message and the Makefile to understand what the command is doing:

```bash
# See what the command does
cat Makefile | grep -A 5 "target-name"

# Run commands manually to debug
```

---

## Examples from DevOps Studio Labs

### Lab 01: Terraform Foundations

```bash
# Set up backend
make setup-backend

# Deploy infrastructure
make apply ENV=dev

# View outputs
make output

# Clean up
make destroy ENV=dev
```

### Lab 02: Kubernetes Platform

```bash
# Deploy EKS cluster
make apply

# Configure kubectl
make configure-kubectl

# Deploy application with Helm
make deploy-helm-chart

# Validate Helm charts
make lint-helm
make validate-helm
```

### Lab 03: CI/CD Pipelines

```bash
# Set up environment
make setup

# Run tests
make test

# Build and deploy
make build
make deploy-staging
```

---

## Advanced Usage

### Running Commands in Parallel

Some Makefiles support parallel execution:

```bash
make -j4 test  # Run 4 test jobs in parallel
```

### Dry Run

See what a command would do without executing:

```bash
make -n deploy  # Dry run (no execution)
```

### Verbose Output

See all commands being executed:

```bash
make VERBOSE=1 deploy
```

---

## Learning More

### Official Documentation

- [GNU Make Manual](https://www.gnu.org/software/make/manual/)
- [Make Tutorial](https://makefiletutorial.com/)

### Practice

The best way to learn Makefiles is to:
1. Start with `make help` in any lab
2. Try the commands one by one
3. Read the Makefile to understand what they do
4. Modify commands to suit your needs

---

## Summary

**Key Takeaways**:
- ✅ Makefiles simplify complex commands
- ✅ Use `make help` to see available commands
- ✅ Commands are lab-specific
- ✅ Environment variables customize behavior
- ✅ Read Makefiles to understand what commands do

**Next Steps**:
1. Navigate to any lab directory
2. Run `make help`
3. Try a few commands
4. Read the Makefile to understand the structure

---

**Questions?** Check the lab-specific README or the Makefile comments for more details!

