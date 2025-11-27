# Trivy - Vulnerability Scanning

Trivy is a comprehensive security scanner that finds vulnerabilities in container images, filesystems, Git repositories, and infrastructure as code.

## Overview

Trivy provides:
- **Container Image Scanning** - Find vulnerabilities in Docker images
- **Filesystem Scanning** - Scan local filesystems
- **IaC Scanning** - Scan Terraform, CloudFormation, Kubernetes manifests
- **Git Repository Scanning** - Scan code repositories
- **Kubernetes Scanning** - Scan entire Kubernetes clusters

## Installation

### macOS

```bash
brew install trivy
```

### Linux

```bash
# Download binary
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

### Verify Installation

```bash
trivy --version
```

## Usage

### Container Image Scanning

```bash
# Scan a Docker image
trivy image nginx:latest

# Scan with specific severity levels
trivy image --severity HIGH,CRITICAL nginx:latest

# Scan and output JSON
trivy image --format json --output results.json nginx:latest

# Scan and exit with error code on vulnerabilities
trivy image --exit-code 1 --severity CRITICAL nginx:latest
```

### Filesystem Scanning

```bash
# Scan current directory
trivy fs .

# Scan specific directory
trivy fs /path/to/application

# Scan with ignore file
trivy fs --ignorefile .trivyignore .
```

### Infrastructure as Code Scanning

```bash
# Scan Terraform files
trivy config terraform/

# Scan Kubernetes manifests
trivy k8s cluster

# Scan CloudFormation templates
trivy config cloudformation/
```

### Kubernetes Cluster Scanning

```bash
# Scan entire cluster
trivy k8s cluster

# Scan specific namespace
trivy k8s cluster --namespace devops-studio

# Scan with report output
trivy k8s cluster --format table --output cluster-report.txt
```

## Configuration

### Trivy Config File

Create `config.yaml`:

```yaml
# Trivy configuration
format: table
severity:
  - UNKNOWN
  - LOW
  - MEDIUM
  - HIGH
  - CRITICAL

# Ignore specific vulnerabilities
ignore:
  - CVE-2021-12345
  - CVE-2021-67890

# Skip certain checks
skip:
  - os-pkgs
  - lang-pkgs
```

### Ignore File

Create `.trivyignore`:

```
# Ignore specific CVEs
CVE-2021-12345
CVE-2021-67890

# Ignore by package
node_modules
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.IMAGE }}
    format: 'sarif'
    output: 'trivy-results.sarif'
    severity: 'CRITICAL,HIGH'
```

### GitLab CI

```yaml
trivy-scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --exit-code 0 --severity HIGH,CRITICAL $IMAGE
```

## Best Practices

### Scanning Strategy

1. **Pre-commit**: Scan code and IaC
2. **CI/CD**: Scan images before push
3. **Pre-deploy**: Scan images before deployment
4. **Post-deploy**: Scan running cluster

### Severity Levels

- **CRITICAL**: Fix immediately
- **HIGH**: Fix within 24 hours
- **MEDIUM**: Fix within 1 week
- **LOW**: Fix when convenient

### Ignoring Vulnerabilities

Only ignore vulnerabilities if:
- False positive confirmed
- Vulnerability not exploitable in your context
- Fix is in progress (with timeline)

## Additional Resources

- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Trivy GitHub](https://github.com/aquasecurity/trivy)

