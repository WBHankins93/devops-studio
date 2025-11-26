# GitHub Actions Workflows

This directory contains GitHub Actions workflows for CI/CD automation.

## Workflows

### CI Pipeline (`ci.yml`)

Runs on every push and pull request:
- **Test**: Runs unit and integration tests
- **Build**: Builds Docker image and pushes to ECR
- **Security Scan**: Scans Docker image for vulnerabilities

### CD Pipeline (`cd.yml`)

Runs on pushes to `main` branch:
- **Deploy Staging**: Automatically deploys to staging environment
- **Deploy Production**: Manual deployment to production (via workflow_dispatch)

## Setup

1. Copy workflows to your repository:
   ```bash
   cp -r github-actions/.github ../../.github/
   ```

2. Configure GitHub Secrets (Repository Settings > Secrets):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `AWS_ACCOUNT_ID`
   - `EKS_CLUSTER_NAME` (optional, if deploying to Kubernetes)

3. Push code to trigger workflows

## Usage

Workflows run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual trigger via `workflow_dispatch`

## Customization

Edit workflow files to:
- Change trigger conditions
- Add additional test stages
- Modify deployment targets
- Add notification steps

