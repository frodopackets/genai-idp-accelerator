#!/bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

# Post-deployment configuration script for IDP Pattern 2
# This script handles the Parameter Store configuration and IAM permissions
# that are required after the Terraform deployment completes.

set -e

# Default values
REGION="us-east-1"
STACK_PREFIX="idp-pattern2-example"
ACCOUNT_ID=""
VERSION="0.3.10"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --region)
      REGION="$2"
      shift 2
      ;;
    --stack-prefix)
      STACK_PREFIX="$2"
      shift 2
      ;;
    --account-id)
      ACCOUNT_ID="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --region REGION          AWS region (default: us-east-1)"
      echo "  --stack-prefix PREFIX    Stack prefix (default: idp-pattern2-example)"
      echo "  --account-id ACCOUNT     AWS Account ID (required)"
      echo "  --version VERSION        Version string (default: 0.3.10)"
      echo "  -h, --help              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [ -z "$ACCOUNT_ID" ]; then
  echo "Error: --account-id is required"
  echo "Run with --help for usage information"
  exit 1
fi

echo "=== IDP Pattern 2 Post-Deployment Configuration ==="
echo "Region: $REGION"
echo "Stack Prefix: $STACK_PREFIX"
echo "Account ID: $ACCOUNT_ID"
echo "Version: $VERSION"
echo

# Construct resource names based on Terraform naming convention
PARAMETER_NAME="/${STACK_PREFIX}/settings"
INPUT_BUCKET="${STACK_PREFIX}-pattern2-input-${ACCOUNT_ID}"
OUTPUT_BUCKET="${STACK_PREFIX}-pattern2-output-${ACCOUNT_ID}"
WORKING_BUCKET="${STACK_PREFIX}-pattern2-working-${ACCOUNT_ID}"
COGNITO_ROLE_NAME="${STACK_PREFIX}-pattern2-cognito-authenticated-role"
POLICY_NAME="${STACK_PREFIX}-pattern2-cognito-authenticated-policy"

echo "Step 1: Creating Parameter Store parameter..."
# Create the Parameter Store parameter with application settings
PARAMETER_VALUE=$(cat <<EOF
{
  "InputBucket": "$INPUT_BUCKET",
  "OutputBucket": "$OUTPUT_BUCKET", 
  "WorkingBucket": "$WORKING_BUCKET",
  "Version": "$VERSION",
  "StackName": "$STACK_PREFIX",
  "IDPPattern": "Pattern 2 - Accelerated Intelligent Document Processing on AWS"
}
EOF
)

aws ssm put-parameter \
  --name "$PARAMETER_NAME" \
  --value "$PARAMETER_VALUE" \
  --type "String" \
  --description "IDP Pattern 2 React application settings" \
  --region "$REGION" \
  --overwrite

echo "✓ Parameter Store parameter created: $PARAMETER_NAME"

echo
echo "Step 2: Adding SSM permissions to Cognito authenticated role..."

# Get the existing policy document
EXISTING_POLICY=$(aws iam get-role-policy \
  --role-name "$COGNITO_ROLE_NAME" \
  --policy-name "$POLICY_NAME" \
  --query "PolicyDocument" \
  --output json)

# Add SSM permission to the existing policy
UPDATED_POLICY=$(echo "$EXISTING_POLICY" | jq --arg param_arn "arn:aws:ssm:$REGION:$ACCOUNT_ID:parameter$PARAMETER_NAME" '
  .Statement += [{
    "Action": ["ssm:GetParameter"],
    "Effect": "Allow", 
    "Resource": [$param_arn]
  }]
')

# Update the role policy
aws iam put-role-policy \
  --role-name "$COGNITO_ROLE_NAME" \
  --policy-name "$POLICY_NAME" \
  --policy-document "$UPDATED_POLICY"

echo "✓ SSM permissions added to Cognito authenticated role"

echo
echo "Step 3: Updating React application environment..."

# Create the production environment file
ENV_FILE="/tmp/env.production"
cat > "$ENV_FILE" <<EOF
# Production environment variables for IDP Pattern 2 UI
# Generated from Terraform deployment

REACT_APP_AWS_REGION=$REGION
REACT_APP_USER_POOL_ID=\${user_pool_id}
REACT_APP_USER_POOL_CLIENT_ID=\${user_pool_client_id}
REACT_APP_IDENTITY_POOL_ID=\${identity_pool_id}
REACT_APP_APPSYNC_GRAPHQL_URL=\${appsync_url}

# S3 Bucket Configuration
REACT_APP_INPUT_BUCKET=$INPUT_BUCKET
REACT_APP_OUTPUT_BUCKET=$OUTPUT_BUCKET
REACT_APP_WORKING_BUCKET=$WORKING_BUCKET

# Parameter Store Configuration
REACT_APP_SETTINGS_PARAMETER=$PARAMETER_NAME
EOF

echo "✓ Environment template created at $ENV_FILE"
echo "  Note: Replace placeholder values with actual Terraform outputs"

echo
echo "=== Configuration Complete ==="
echo "Next steps:"
echo "1. Update the React app environment file with Terraform outputs"
echo "2. Build and deploy the React application"
echo "3. Create CloudFront invalidation if needed"
echo
echo "React build command:"
echo "  GENERATE_SOURCEMAP=false INLINE_RUNTIME_CHUNK=false NODE_OPTIONS=\"--max-old-space-size=4096\" npm run build"
echo
echo "Deploy to S3:"
echo "  aws s3 sync build/ s3://\${WEB_BUCKET_NAME} --delete --region $REGION"