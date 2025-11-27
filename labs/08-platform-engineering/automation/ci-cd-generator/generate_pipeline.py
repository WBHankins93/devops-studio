#!/usr/bin/env python3
"""
CI/CD Pipeline Generator
Generates GitHub Actions workflows from templates.
"""

import os
import json
from pathlib import Path
from typing import Dict, Any

PIPELINE_TEMPLATES = {
    "standard-web-app": """name: Deploy {service_name}

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  AWS_REGION: {aws_region}
  SERVICE_NAME: {service_name}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          echo "Running tests for {service_name}"
          # Add your test commands here

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: |
          docker build -t {service_name}:${{ github.sha }} .
          # Add your build commands here

  deploy-dev:
    needs: build
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: dev
    steps:
      - uses: actions/checkout@v3
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: {aws_region}
      - name: Deploy to dev
        run: |
          cd infrastructure
          terraform init
          terraform apply -auto-approve

  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v3
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: {aws_region}
      - name: Deploy to staging
        run: |
          cd infrastructure
          terraform init
          terraform apply -auto-approve

  deploy-prod:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: {aws_region}
      - name: Deploy to production
        run: |
          cd infrastructure
          terraform init
          terraform apply -auto-approve
""",
    
    "serverless-api": """name: Deploy {service_name}

on:
  push:
    branches: [main]

env:
  AWS_REGION: {aws_region}
  SERVICE_NAME: {service_name}

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: {aws_region}
      - name: Deploy Lambda
        run: |
          cd lambda
          zip -r function.zip .
          aws lambda update-function-code \\
            --function-name {service_name} \\
            --zip-file fileb://function.zip
"""
}

class PipelineGenerator:
    def __init__(self, service_name: str, repository: str, template: str, environments: list, aws_region: str = "us-west-2"):
        self.service_name = service_name
        self.repository = repository
        self.template = template
        self.environments = environments
        self.aws_region = aws_region
        
    def generate(self, output_path: str = ".github/workflows/deploy.yml"):
        """Generate pipeline file."""
        if self.template not in PIPELINE_TEMPLATES:
            raise ValueError(f"Unknown template: {self.template}")
            
        template_content = PIPELINE_TEMPLATES[self.template]
        
        # Replace placeholders
        content = template_content.format(
            service_name=self.service_name,
            aws_region=self.aws_region,
            repository=self.repository
        )
        
        # Write to file
        output_file = Path(output_path)
        output_file.parent.mkdir(parents=True, exist_ok=True)
        output_file.write_text(content)
        
        return {
            "status": "generated",
            "file": str(output_file),
            "template": self.template
        }

def main():
    """CLI entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description="CI/CD Pipeline Generator")
    parser.add_argument("--service", required=True)
    parser.add_argument("--repository", required=True)
    parser.add_argument("--template", required=True, choices=list(PIPELINE_TEMPLATES.keys()))
    parser.add_argument("--environments", nargs="+", default=["dev", "staging", "prod"])
    parser.add_argument("--aws-region", default="us-west-2")
    parser.add_argument("--output", default=".github/workflows/deploy.yml")
    
    args = parser.parse_args()
    
    generator = PipelineGenerator(
        service_name=args.service,
        repository=args.repository,
        template=args.template,
        environments=args.environments,
        aws_region=args.aws_region
    )
    
    result = generator.generate(args.output)
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()

