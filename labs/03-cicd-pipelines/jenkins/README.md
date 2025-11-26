# Jenkins Pipeline

This directory contains Jenkins pipeline configuration using Jenkinsfile.

## Setup

1. **Install Jenkins** (if not already installed):
   - Local: Use Docker or install directly
   - Server: Follow Jenkins installation guide

2. **Install Required Plugins**:
   - Pipeline
   - Docker Pipeline
   - Kubernetes
   - Git
   - AWS Steps (optional)

3. **Configure Credentials** (Manage Jenkins > Credentials):
   - AWS Access Key ID and Secret Access Key
   - Docker Registry credentials (if needed)
   - Kubernetes kubeconfig (if deploying to K8s)

4. **Create Pipeline**:
   - New Item > Pipeline
   - Select "Pipeline script from SCM"
   - Set SCM to Git
   - Point to repository with Jenkinsfile
   - Script Path: `labs/03-cicd-pipelines/jenkins/Jenkinsfile`

5. **Configure Environment Variables**:
   - `AWS_REGION`: AWS region (default: us-west-2)
   - `AWS_ACCOUNT_ID`: Your AWS account ID
   - `EKS_CLUSTER_NAME`: EKS cluster name (if deploying)

## Pipeline Stages

1. **Checkout**: Get source code
2. **Test**: Run unit and integration tests in parallel
3. **Build**: Build and push Docker image to ECR
4. **Security Scan**: Scan image for vulnerabilities
5. **Deploy Staging**: Deploy to staging environment
6. **Deploy Production**: Manual approval required

## Usage

- Build automatically on push (if webhook configured)
- Or trigger manually from Jenkins UI
- Production deployment requires manual approval

## Customization

Edit `Jenkinsfile` to:
- Add additional stages
- Modify test commands
- Change deployment strategies
- Add notifications

