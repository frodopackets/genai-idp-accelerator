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

### UI Deployment Process

After Terraform deployment:

1. **Infrastructure Ready**: Backend services and UI infrastructure are deployed
2. **React Application**: Build the React app from `/src/ui/` directory
3. **Configuration**: Use Terraform outputs to configure the React app
4. **Deploy**: Upload built assets to the S3 web UI bucket
5. **Access**: Navigate to the CloudFront URL to use the application

**Example Configuration Commands:**
```bash
# Get UI configuration from Terraform outputs
terraform output ui_configuration

# Build and deploy React application
cd /src/ui
npm install
npm run build

# Deploy to S3 (replace with actual bucket name from outputs)
aws s3 sync build/ s3://your-web-ui-bucket-name/

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
```

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

### Security Considerations

- All resources use customer-managed KMS keys
- IAM roles follow least privilege principles
- Support for organizational compliance (permissions boundaries)
- CloudWatch logging enabled for all components
- Dead letter queues for error handling

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