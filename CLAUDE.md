# Claude Code Instructions for IDP Project

This document provides instructions for Claude Code when working with the Intelligent Document Processing (IDP) project.

## Project Overview

This project provides a scalable, serverless solution for automated document processing and information extraction using AWS services. The solution combines OCR capabilities with generative AI to convert unstructured documents into structured data at scale.

### Processing Patterns

- **Pattern 1**: Packet or Media processing with Bedrock Data Automation (BDA)
- **Pattern 2**: OCR → Bedrock Classification (page-level or holistic) → Bedrock Extraction
- **Pattern 3**: OCR → UDOP Classification (SageMaker) → Bedrock Extraction

## Terraform Implementation (Pattern 2)

### Overview

Pattern 2 has been refactored to use Terraform instead of CloudFormation. The Terraform module is located at `terraform/modules/pattern-2/` and follows AWS best practices for infrastructure as code.

### Module Structure

```
terraform/modules/pattern-2/
├── README.md                     # Module documentation
├── main.tf                       # Main module orchestration
├── variables.tf                  # Input variables
├── outputs.tf                    # Output values
├── versions.tf                   # Provider requirements
├── locals.tf                     # Local values
├── modules/
│   ├── lambda-functions/         # Lambda function submodule
│   ├── step-functions/           # Step Functions workflow submodule
│   ├── monitoring/               # CloudWatch dashboard and metrics
│   ├── configuration/            # DynamoDB configuration management
│   ├── cognito/                  # User authentication and authorization
│   ├── appsync/                  # GraphQL API for UI integration
│   └── web-hosting/              # CloudFront + S3 for web UI hosting
└── examples/
    └── basic/                    # Basic deployment example
```

### Key Features

- **Complete Full-Stack Solution**: Backend processing + Web UI infrastructure
- **Modular Design**: Organized into logical submodules for maintainability
- **Security Best Practices**: 
  - Least privilege IAM roles
  - KMS encryption for all resources
  - Support for IAM permissions boundaries
  - Cognito authentication with MFA support
  - CloudFront security headers and WAF integration
- **Web UI Infrastructure**:
  - Cognito User Pool for authentication
  - AppSync GraphQL API with 20+ operations
  - CloudFront + S3 for global content delivery
  - React application hosting capability
- **Monitoring**: CloudWatch dashboard and alarms for all components
- **Configuration Management**: Schema-based configuration with validation
- **Example Deployments**: Working examples for different use cases

### Usage Instructions

#### Basic Deployment

1. **Navigate to the basic example:**
   ```bash
   cd terraform/modules/pattern-2/examples/basic
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Plan and apply:**
   ```bash
   terraform plan
   terraform apply
   ```

#### Using the Module

```hcl
module "pattern_2" {
  source = "../../modules/pattern-2"

  stack_name                   = "my-idp-pattern2"
  input_bucket                 = aws_s3_bucket.input.id
  configuration_bucket         = aws_s3_bucket.config.id
  output_bucket                = aws_s3_bucket.output.id
  working_bucket               = aws_s3_bucket.working.id
  tracking_table               = aws_dynamodb_table.tracking.name
  configuration_table          = aws_dynamodb_table.config.name
  customer_managed_key_arn     = aws_kms_key.idp.arn
  
  # Optional features
  is_summarization_enabled     = true
  is_assessment_enabled        = false
  
  # Environment configuration
  environment                  = "production"
  log_level                   = "INFO"
  log_retention_days          = 30
  
  tags = {
    Project     = "IDP"
    Environment = "production"
  }
}
```

### Prerequisites

Before deploying Pattern 2 with Terraform:

1. **AWS CLI configured** with appropriate permissions
2. **Terraform >= 1.0** installed
3. **Access to Amazon Bedrock models** (Claude 3.5 Haiku, Claude 3.5 Sonnet, Nova models)
4. **Target AWS Account**: 723648924038
5. **Default AWS Region**: us-east-1
6. **Required AWS permissions** for:
   - S3 bucket management
   - Lambda function deployment
   - Step Functions state machines
   - IAM role creation
   - KMS key management
   - CloudWatch dashboards and alarms
   - Cognito User Pool and Identity Pool management
   - AppSync API creation and configuration
   - CloudFront distribution management
   - Route53 record management (if using custom domain)

### AWS Account Configuration

**IMPORTANT**: All deployments should target AWS account **723648924038** in the **us-east-1** region. When working with AWS resources:

- Verify AWS CLI is configured for account 723648924038
- Use us-east-1 as the default region for all resources
- Double-check account ID in any AWS console URLs or ARNs
- Ensure IAM permissions are scoped to the correct account

### Development Workflow

When working on the Terraform module, follow these steps:

1. **Validate configuration:**
   ```bash
   terraform validate
   ```

2. **Run security scan:**
   ```bash
   checkov -d . --framework terraform
   ```

3. **Initialize and plan:**
   ```bash
   terraform init
   terraform plan
   ```

4. **Apply only after review:**
   ```bash
   terraform apply
   ```

### Common Commands

- **Lint and validate code:**
  ```bash
  terraform fmt -recursive
  terraform validate
  ```

- **Test example deployment:**
  ```bash
  cd terraform/modules/pattern-2/examples/basic
  terraform init
  terraform plan
  terraform apply
  ```

- **Clean up resources:**
  ```bash
  terraform destroy
  ```

### Complete Infrastructure Components

Pattern 2 now provides complete full-stack infrastructure:

#### Backend Processing
- **Lambda Functions**: OCR, Classification, Extraction, Assessment, Summarization, Process Results
- **Step Functions**: Orchestrates document processing workflow
- **DynamoDB**: Document tracking and configuration management
- **S3 Buckets**: Input, output, working, and configuration storage
- **CloudWatch**: Comprehensive monitoring and alerting

#### Frontend Infrastructure  
- **Cognito**: User authentication with configurable password policies and MFA
- **AppSync**: GraphQL API with 20+ operations for document management
- **CloudFront + S3**: Global CDN for React application hosting
- **Security**: Response headers, CORS configuration, and access controls

#### Web UI Capabilities (React Application)
The infrastructure supports a complete React web application with:
- Document upload and management
- Real-time processing status monitoring
- Document analytics and querying
- Configuration management interface
- Step Function execution visualization
- Knowledge base integration

### Configuration Schema

Pattern 2 supports the following configuration options:

- **OCR Configuration**: Backend selection (Textract/Bedrock), DPI settings, image processing
- **Classification**: Method selection, model choice, concurrency settings
- **Extraction**: Model selection, parallel processing configuration
- **UI Configuration**: Cognito settings, custom domain, admin users
- **Monitoring**: Log levels, retention periods, alert thresholds

See `terraform/modules/pattern-2/locals.tf` for the complete schema definition.

### Complete Deployment Process

#### 1. Infrastructure Deployment (Terraform)

```bash
cd terraform/modules/pattern-2/examples/basic
terraform init
terraform plan
terraform apply
```

#### 2. Post-Deployment Configuration

**CRITICAL STEP**: The React application requires additional configuration after Terraform deployment:

```bash
# Run the automated post-deployment configuration script
cd terraform/modules/pattern-2/scripts
./post-deploy-config.sh \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --region us-east-1 \
  --stack-prefix idp-pattern2-example
```

This script:
- Creates the AWS Systems Manager Parameter Store parameter for app settings
- Adds SSM read permissions to the Cognito authenticated user role
- Generates environment file template for the React app

#### 3. React Application Configuration

Update `src/ui/.env.production` with Terraform outputs:

```bash
# Production environment variables (replace with actual values)
REACT_APP_AWS_REGION=us-east-1
REACT_APP_USER_POOL_ID=us-east-1_XXXXXXXXX
REACT_APP_USER_POOL_CLIENT_ID=XXXXXXXXXXXXXXXXXXXXXXXXXX
REACT_APP_IDENTITY_POOL_ID=us-east-1:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
REACT_APP_APPSYNC_GRAPHQL_URL=https://XXXXXXXXXXXXXXXXXXXXXXXXXX.appsync-api.us-east-1.amazonaws.com/graphql
REACT_APP_INPUT_BUCKET=idp-pattern2-example-pattern2-input-XXXXXXXXXXXX
REACT_APP_OUTPUT_BUCKET=idp-pattern2-example-pattern2-output-XXXXXXXXXXXX
REACT_APP_WORKING_BUCKET=idp-pattern2-example-pattern2-working-XXXXXXXXXXXX
REACT_APP_SETTINGS_PARAMETER=/idp-pattern2-example/settings
```

#### 4. Build and Deploy React Application

**Use the optimized build script** to avoid memory and performance issues:

```bash
cd src/ui
./scripts/build-optimized.sh
```

Or manually with optimization flags:
```bash
GENERATE_SOURCEMAP=false INLINE_RUNTIME_CHUNK=false NODE_OPTIONS="--max-old-space-size=4096" npm run build
```

Deploy to S3:
```bash
aws s3 sync build/ s3://YOUR_WEB_UI_BUCKET_NAME --delete --region us-east-1
```

#### 5. CloudFront Cache Invalidation

After deployment, clear the CloudFront cache:
```bash
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
```

### 🚨 Critical Deployment Requirements

#### Parameter Store Integration
The React application **requires** AWS Systems Manager Parameter Store configuration:

- **Parameter Name**: `/idp-pattern2-example/settings` (configurable via stack prefix)
- **Parameter Value**: JSON object containing `InputBucket`, `OutputBucket`, `WorkingBucket`, and app metadata
- **IAM Permissions**: Cognito authenticated users must have `ssm:GetParameter` permission

#### React Build Optimization
Standard `npm run build` may hang due to memory issues. **Always use**:
- `GENERATE_SOURCEMAP=false` - Reduces build size and time
- `INLINE_RUNTIME_CHUNK=false` - Prevents inlining issues  
- `NODE_OPTIONS="--max-old-space-size=4096"` - Increases memory limit

#### Content Security Policy (CSP)
The updated Terraform module includes React-friendly CSP headers:
- Allows `data:` and `blob:` sources for dynamic content
- Permits `unsafe-inline` styles for React
- Includes Cognito endpoints in `connect-src`
- Uses standard `Content-Security-Policy` header (not `X-Content-Security-Policy`)

## Working with Claude Code

### Testing Changes

When making changes to the Terraform module:

1. Always validate configuration first
2. Run security scanning with Checkov
3. Test with the basic example before deploying to production
4. Use the monitoring dashboard to verify deployment health

### File Organization

- Keep Terraform files organized by function (main.tf, variables.tf, outputs.tf)
- Use submodules for logical groupings of resources
- Include comprehensive documentation in README.md files
- Provide working examples for different use cases

#### New Deployment Assets

The following files have been added to simplify deployment and troubleshooting:

**📋 Terraform Module Files:**
- `terraform/modules/pattern-2/scripts/post-deploy-config.sh` - Post-deployment configuration automation
- `terraform/modules/pattern-2/DEPLOYMENT.md` - Comprehensive deployment guide with troubleshooting

**⚡ React Build Optimization:**
- `src/ui/scripts/build-optimized.sh` - Optimized React build script with memory management

**🔧 Module Improvements:**
- Updated `modules/cognito/main.tf` - Added Parameter Store IAM permissions
- Updated `modules/web-hosting/main.tf` - React-friendly CSP configuration
- Enhanced security headers and CORS policies

### Common Deployment Issues and Solutions

#### Issue: React Build Hangs or Fails
**Symptoms**: Build process hangs at "Creating an optimized production build..." or memory errors

**Solutions**:
1. Use the optimized build script: `./scripts/build-optimized.sh`
2. Clear npm cache: `npm cache clean --force`
3. Delete and reinstall: `rm -rf node_modules package-lock.json && npm install`

#### Issue: "Input bucket not configured" Error
**Symptoms**: React app shows error about missing input bucket configuration

**Root Cause**: Missing Parameter Store configuration or IAM permissions

**Solutions**:
1. Run post-deployment script: `./post-deploy-config.sh`
2. Verify Parameter Store parameter exists: `aws ssm get-parameter --name "/idp-pattern2-example/settings"`
3. Check Cognito IAM role has SSM permissions

#### Issue: Blank White Page  
**Symptoms**: CloudFront URL shows blank page, CSP errors in browser console

**Root Cause**: Overly restrictive Content Security Policy headers

**Solution**: Use updated Terraform module with React-friendly CSP configuration, then create CloudFront invalidation

#### Issue: Authentication Errors
**Symptoms**: Cannot log in, "User does not exist" errors

**Solutions**:
1. Create admin user: `aws cognito-idp admin-create-user --user-pool-id YOUR_POOL_ID --username email@example.com`
2. Set permanent password: `aws cognito-idp admin-set-user-password --user-pool-id YOUR_POOL_ID --username email@example.com --password SecurePassword123! --permanent`

#### Issue: CloudFront/KMS Encryption Conflicts
**Symptoms**: CloudFront 403 errors, "UnrecognizedClientException" from KMS

**Root Cause**: CloudFront cannot decrypt KMS-encrypted S3 objects for static hosting

**Solution**: Use AES256 encryption for web UI bucket (configured in updated module): `customer_managed_key_arn = null`

### Security Considerations

- All resources use customer-managed KMS keys (except web UI bucket for CloudFront compatibility)
- IAM roles follow least privilege principles
- Support for organizational compliance (permissions boundaries)
- CloudWatch logging enabled for all components
- Dead letter queues for error handling
- React-friendly Content Security Policy headers
- Parameter Store integration for secure configuration management

### Monitoring

The Terraform module creates comprehensive monitoring including:

- CloudWatch dashboard for all components
- Alarms for Lambda function errors and duration
- Step Functions execution monitoring
- Dead letter queue alerts

Access the dashboard URL from the Terraform outputs after deployment.

## Branch Information

This Terraform implementation is on the `feature/terraform-pattern2-refactor` branch.

## UI Development Status

### ✅ Completed Infrastructure & Application
- Backend processing (Lambda, Step Functions, DynamoDB, S3)
- User authentication (Cognito User Pool + Identity Pool)
- GraphQL API (AppSync with comprehensive schema)
- Web hosting (CloudFront + S3 with security headers)
- Monitoring and logging (CloudWatch dashboards and alarms)
- **React application built and deployed successfully**

### 🚀 Live Deployment
The complete Pattern 2 application is now operational:

**🌐 Application URL:** https://d1wt4l7lia144o.cloudfront.net

**📊 Key Infrastructure Components:**
- **CloudFront Distribution:** E20ZFPEECFYEG7
- **AppSync GraphQL Endpoint:** https://5ar3j5uudraj5l6ulkgkzqtcim.appsync-api.us-east-1.amazonaws.com/graphql
- **Cognito User Pool:** us-east-1_lCTHtJWY9
- **S3 Web UI Bucket:** idp-pattern2-example-pattern2-web-ui-723648924038

**🔧 Application Features:**
- Document upload and processing pipeline
- User authentication and session management
- Real-time document tracking and status updates
- AI-powered document analysis with Bedrock
- Interactive results visualization
- Configuration management interface

### 🔒 Security & KMS Configuration

**Important**: The KMS key policy has been configured to allow CloudFront access to encrypted S3 objects. This includes:

- **CloudFront Service Access**: Added `cloudfront.amazonaws.com` to allowed services
- **Conditional Decryption**: CloudFront can only decrypt objects via S3 service in us-east-1
- **Resource-Specific Access**: Limited to web UI bucket objects using S3 ARN patterns
- **Secure by Design**: Maintains encryption while enabling proper CDN functionality

This resolves the `KMS.UnrecognizedClientException` error that can occur when CloudFront tries to serve encrypted S3 content.

### 📋 Optional Enhancements
- **WAF Integration**: API security and rate limiting (module exists but not integrated)
- **CodeBuild CI/CD**: Automated React application deployment pipeline
- **Custom Domain**: Route53 + ACM certificate for branded URLs
- **Enhanced Security**: IP restrictions, advanced threat protection

## Next Steps

- **UI Deployment**: Complete React application build and deployment process
- **Pattern 1 and 3**: Consider refactoring to Terraform following the same modular approach
- **CI/CD Integration**: Add automated testing and deployment pipelines for both infrastructure and UI
- **Multi-Environment**: Create environment-specific configurations
- **Module Registry**: Publish module to private Terraform registry if needed
- **Security Hardening**: Implement WAF rules and additional security measures