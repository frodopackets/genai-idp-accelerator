# IDP Pattern 2 Terraform Deployment Guide

This guide provides comprehensive instructions for deploying IDP Pattern 2 using Terraform, including troubleshooting for common issues encountered during deployment.

## Prerequisites

- **Terraform >= 1.0**
- **AWS CLI configured** with appropriate permissions
- **Node.js 18+** and npm (for React app)
- **jq** (for post-deployment configuration)

## Quick Start

1. **Deploy Infrastructure:**
   ```bash
   cd terraform/modules/pattern-2/examples/basic
   terraform init
   terraform plan
   terraform apply
   ```

2. **Run Post-Deployment Configuration:**
   ```bash
   cd ../../scripts
   ./post-deploy-config.sh --account-id YOUR_ACCOUNT_ID --region us-east-1
   ```

3. **Build and Deploy React App:**
   ```bash
   cd ../../../../src/ui
   # Update .env.production with Terraform outputs
   ./scripts/build-optimized.sh
   aws s3 sync build/ s3://YOUR_WEB_BUCKET --delete
   ```

## Detailed Deployment Steps

### Step 1: Infrastructure Deployment

Navigate to the example directory and deploy the infrastructure:

```bash
cd terraform/modules/pattern-2/examples/basic
terraform init
terraform plan -var="admin_user_email=your-email@example.com"
terraform apply -var="admin_user_email=your-email@example.com"
```

**Important Terraform Outputs:**
After deployment, save these outputs for React app configuration:
- `user_pool_id`
- `user_pool_client_id` 
- `identity_pool_id`
- `appsync_graphql_url`
- `website_domain`
- `input_bucket_name`
- `output_bucket_name`
- `working_bucket_name`

### Step 2: Post-Deployment Configuration

The Terraform deployment creates the infrastructure, but additional configuration is needed:

1. **Parameter Store Setup**: The React app requires settings in AWS Systems Manager Parameter Store
2. **IAM Permissions**: Cognito authenticated users need SSM read permissions
3. **React Environment**: Configure the app with Terraform outputs

Run the automated configuration script:

```bash
cd terraform/modules/pattern-2/scripts
./post-deploy-config.sh \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --region us-east-1 \
  --stack-prefix idp-pattern2-example
```

### Step 3: React Application Deployment

#### 3.1 Update Environment Configuration

Create/update `src/ui/.env.production` with Terraform outputs:

```bash
# Production environment variables for IDP Pattern 2 UI
REACT_APP_AWS_REGION=us-east-1
REACT_APP_USER_POOL_ID=us-east-1_XXXXXXXXX
REACT_APP_USER_POOL_CLIENT_ID=XXXXXXXXXXXXXXXXXXXXXXXXXX
REACT_APP_IDENTITY_POOL_ID=us-east-1:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
REACT_APP_APPSYNC_GRAPHQL_URL=https://XXXXXXXXXXXXXXXXXXXXXXXXXX.appsync-api.us-east-1.amazonaws.com/graphql

# S3 Bucket Configuration  
REACT_APP_INPUT_BUCKET=idp-pattern2-example-pattern2-input-XXXXXXXXXXXX
REACT_APP_OUTPUT_BUCKET=idp-pattern2-example-pattern2-output-XXXXXXXXXXXX
REACT_APP_WORKING_BUCKET=idp-pattern2-example-pattern2-working-XXXXXXXXXXXX

# Parameter Store Configuration
REACT_APP_SETTINGS_PARAMETER=/idp-pattern2-example/settings
```

#### 3.2 Build and Deploy React App

```bash
cd src/ui

# Install dependencies (if not already done)
npm ci

# Build with optimizations
./scripts/build-optimized.sh

# Deploy to S3
aws s3 sync build/ s3://YOUR_WEB_BUCKET_NAME --delete --region us-east-1

# Create CloudFront invalidation (if needed)
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

## Architecture Components

### Backend Services
- **AWS Lambda**: Document processing functions
- **Amazon Bedrock**: AI/ML model integration (Claude 3.5, Nova models)
- **Amazon Textract**: OCR processing
- **AWS Step Functions**: Workflow orchestration
- **Amazon DynamoDB**: Document metadata storage
- **Amazon S3**: Document storage (input, output, working buckets)

### Frontend Infrastructure
- **Amazon Cognito**: User authentication and authorization
- **AWS AppSync**: GraphQL API gateway
- **Amazon CloudFront**: CDN for global content delivery
- **Amazon S3**: Static web hosting
- **AWS Systems Manager**: Parameter Store for app configuration

### Security Features
- **KMS Encryption**: Customer-managed keys for S3 buckets
- **IAM Least Privilege**: Minimal required permissions
- **VPC Integration**: Optional VPC deployment for isolation
- **Content Security Policy**: Strict CSP headers for web security
- **WAF Integration**: Web Application Firewall protection (optional)

## Common Issues and Solutions

### Issue 1: React Build Hangs or Fails

**Symptoms:**
- Build process hangs at "Creating an optimized production build..."
- Out of memory errors during build
- Build taking excessively long (>10 minutes)

**Solutions:**
1. **Use the optimized build script:**
   ```bash
   cd src/ui
   ./scripts/build-optimized.sh
   ```

2. **Manual build with flags:**
   ```bash
   GENERATE_SOURCEMAP=false INLINE_RUNTIME_CHUNK=false NODE_OPTIONS="--max-old-space-size=4096" npm run build
   ```

3. **Clear npm cache and reinstall:**
   ```bash
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

### Issue 2: "Input bucket not configured" Error

**Symptoms:**
- React app displays "Input bucket not configured" error
- Upload functionality not working

**Root Cause:** Missing Parameter Store configuration or IAM permissions

**Solutions:**
1. **Verify Parameter Store parameter exists:**
   ```bash
   aws ssm get-parameter --name "/idp-pattern2-example/settings" --region us-east-1
   ```

2. **Check Cognito IAM role permissions:**
   ```bash
   aws iam get-role-policy \
     --role-name "idp-pattern2-example-pattern2-cognito-authenticated-role" \
     --policy-name "idp-pattern2-example-pattern2-cognito-authenticated-policy"
   ```

3. **Run post-deployment script if not done:**
   ```bash
   cd terraform/modules/pattern-2/scripts
   ./post-deploy-config.sh --account-id YOUR_ACCOUNT --region us-east-1
   ```

### Issue 3: Blank White Page

**Symptoms:**
- CloudFront URL shows blank white page
- Browser console shows Content Security Policy (CSP) errors

**Root Cause:** Overly restrictive CSP headers blocking React resources

**Solution:** The updated Terraform module includes proper CSP configuration. If deployed with an older version:

1. **Update CloudFront Response Headers Policy:**
   ```bash
   # Get policy ID
   aws cloudfront list-response-headers-policies \
     --query "ResponseHeadersPolicyList.Items[?ResponseHeadersPolicy.ResponseHeadersPolicyConfig.Name=='idp-pattern2-example-security-headers'].ResponseHeadersPolicy.Id" \
     --output text
   
   # Update with React-friendly CSP (use updated Terraform module)
   terraform apply
   ```

2. **Create CloudFront invalidation:**
   ```bash
   aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
   ```

### Issue 4: Authentication/Authorization Errors

**Symptoms:**
- Cannot log in to the application
- "User does not exist" errors
- Token validation failures

**Solutions:**
1. **Create admin user:**
   ```bash
   aws cognito-idp admin-create-user \
     --user-pool-id YOUR_USER_POOL_ID \
     --username your-email@example.com \
     --user-attributes Name=email,Value=your-email@example.com Name=name,Value="Your Name" \
     --temporary-password TempPassword123! \
     --message-action SUPPRESS
   ```

2. **Set permanent password:**
   ```bash
   aws cognito-idp admin-set-user-password \
     --user-pool-id YOUR_USER_POOL_ID \
     --username your-email@example.com \
     --password YourSecurePassword123! \
     --permanent
   ```

### Issue 5: CloudFront/KMS Encryption Conflicts

**Symptoms:**
- CloudFront cannot access S3 objects
- 403 Forbidden errors from CloudFront
- "UnrecognizedClientException" errors

**Root Cause:** CloudFront cannot decrypt KMS-encrypted S3 objects for static web hosting

**Solution:** Use AES256 encryption for web UI bucket (already configured in updated module):
```hcl
# In main module call
module "pattern_2" {
  source = "./modules/pattern-2"
  
  # Use AES256 for web UI bucket
  customer_managed_key_arn = null  # This uses AES256
}
```

## Security Best Practices

### 1. Least Privilege IAM
- Cognito authenticated users have minimal required permissions
- Lambda functions use role-specific policies
- Cross-service access is explicitly defined

### 2. Encryption
- KMS encryption for document storage buckets
- AES256 encryption for web UI bucket (CloudFront compatible)
- Encryption in transit for all communications

### 3. Network Security
- Optional VPC deployment for backend services
- Security groups with minimal required ports
- Private subnets for sensitive components

### 4. Content Security Policy
- Strict CSP headers prevent XSS attacks
- Specific origins allowed for AWS services
- No unsafe inline scripts except where required by React

### 5. Access Logging
- CloudFront access logs for monitoring
- S3 access logs for audit trail
- CloudWatch logs for application monitoring

## Monitoring and Troubleshooting

### CloudWatch Logs
Key log groups to monitor:
- `/aws/lambda/idp-pattern2-*`: Lambda function logs
- `/aws/stepfunctions/idp-pattern2-*`: Step Function execution logs
- `/aws/appsync/apis/*/requests`: AppSync API request logs

### Key Metrics
- Lambda invocation errors and duration
- Step Function execution status
- DynamoDB read/write capacity utilization
- S3 request metrics and error rates

### Troubleshooting Commands

```bash
# Check recent Lambda errors
aws logs filter-log-events \
  --log-group-name "/aws/lambda/idp-pattern2-document-processor" \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s)000

# Monitor Step Function executions
aws stepfunctions list-executions \
  --state-machine-arn YOUR_STATE_MACHINE_ARN \
  --status-filter FAILED

# Check DynamoDB table status
aws dynamodb describe-table --table-name idp-pattern2-example-documents
```

## Cost Optimization

### Estimated Monthly Costs (us-east-1)
- **AWS Lambda**: $2-10 (depending on processing volume)
- **Amazon Bedrock**: $50-200 (based on token usage)
- **Amazon Textract**: $15-50 (per 1000 pages)
- **DynamoDB**: $1-5 (with on-demand pricing)
- **S3 Storage**: $1-10 (depending on data volume)
- **CloudFront**: $1-5 (first 1TB free)
- **Other Services**: $5-15 (AppSync, Cognito, etc.)

**Total Estimated**: $75-300/month for moderate usage

### Cost Optimization Tips
1. **Use S3 Lifecycle Policies**: Automatically move old documents to cheaper storage classes
2. **Optimize Lambda Memory**: Right-size Lambda functions based on actual usage
3. **Monitor Bedrock Usage**: Track token consumption and optimize prompts
4. **Use Reserved Capacity**: For predictable DynamoDB workloads
5. **Enable CloudWatch Cost Anomaly Detection**: Get alerts for unexpected spend

## Support and Contributing

### Getting Help
1. Check this deployment guide for common issues
2. Review CloudWatch logs for specific error messages  
3. Validate all prerequisites and configuration steps
4. Check AWS service quotas and limits

### Contributing Improvements
When contributing fixes or improvements:
1. Test changes thoroughly in a separate AWS account
2. Update this deployment guide with any new steps
3. Add troubleshooting entries for new issues discovered
4. Follow AWS security best practices

---

For additional support or questions, refer to the main project README or create an issue in the repository.