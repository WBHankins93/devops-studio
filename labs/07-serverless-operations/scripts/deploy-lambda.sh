#!/bin/bash
# Deploy Lambda function manually (for testing)

set -euo pipefail

FUNCTION_NAME=$1
FUNCTION_DIR=$2

if [ -z "$FUNCTION_NAME" ] || [ -z "$FUNCTION_DIR" ]; then
    echo "Usage: $0 <function-name> <function-directory>"
    echo "Example: $0 hello-world lambda/hello-world"
    exit 1
fi

echo "Deploying $FUNCTION_NAME from $FUNCTION_DIR..."

# Create deployment package
cd "$FUNCTION_DIR"
zip -r function.zip lambda_function.py

# Update Lambda function code
aws lambda update-function-code \
  --function-name "$FUNCTION_NAME" \
  --zip-file fileb://function.zip

echo "✅ Function deployed successfully!"

