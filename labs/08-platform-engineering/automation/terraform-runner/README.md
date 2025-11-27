# Terraform Runner

Automates Terraform execution for service provisioning.

## Overview

The Terraform Runner executes Terraform plans and applies in isolated workspaces, managing state and handling errors.

## Features

- **Workspace Isolation**: Each service gets its own Terraform workspace
- **State Management**: Centralized state storage in S3
- **Plan Review**: Generate and review plans before applying
- **Error Handling**: Automatic rollback on failures
- **Audit Logging**: Complete audit trail of all operations

## Usage

### Basic Execution

```bash
terraform-runner plan \
  --template web-app \
  --workspace my-app-dev \
  --parameters app_name=my-app,environment=dev
```

### Apply with Approval

```bash
terraform-runner apply \
  --workspace my-app-dev \
  --approve
```

## Implementation

This would typically be implemented as:
- Lambda function (for API-triggered execution)
- GitHub Action (for Git-based workflows)
- CLI tool (for local development)

## State Management

- State stored in S3: `s3://platform-state/{workspace}/terraform.tfstate`
- State locking via DynamoDB
- State versioning enabled

## Security

- IAM role assumption for execution
- Least privilege permissions
- Encrypted state storage
- Audit logging to CloudWatch

