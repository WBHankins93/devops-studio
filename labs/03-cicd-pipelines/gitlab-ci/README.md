# GitLab CI Configuration

This directory contains GitLab CI/CD pipeline configuration.

## Setup

1. Copy `.gitlab-ci.yml` to your GitLab repository root:
   ```bash
   cp gitlab-ci/.gitlab-ci.yml ../../.gitlab-ci.yml
   ```

2. Configure CI/CD Variables (Settings > CI/CD > Variables):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_ACCOUNT_ID`
   - `AWS_REGION`
   - `KUBECONFIG` (base64 encoded, for Kubernetes deployment)

3. Ensure GitLab Runners are available (shared runners or project-specific)

## Pipeline Stages

1. **Test**: Unit and integration tests
2. **Build**: Docker image build and push to ECR
3. **Security**: Vulnerability scanning with Trivy
4. **Deploy**: Deployment to staging (automatic) and production (manual)

## Usage

- Pipeline runs automatically on push to `main` or `develop`
- Production deployment requires manual approval
- Test results and coverage are available in GitLab UI

## Customization

Edit `.gitlab-ci.yml` to:
- Add additional stages
- Modify runner tags
- Change deployment conditions
- Add notification jobs

