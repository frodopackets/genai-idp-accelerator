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
│   └── configuration/            # DynamoDB configuration management
└── examples/
    └── basic/                    # Basic deployment example
```

### Key Features

- **Modular Design**: Organized into logical submodules for maintainability
- **Security Best Practices**: 
  - Least privilege IAM roles
  - KMS encryption for all resources
  - Support for IAM permissions boundaries
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
4. **Required AWS permissions** for:
   - S3 bucket management
   - Lambda function deployment
   - Step Functions state machines
   - IAM role creation
   - KMS key management
   - CloudWatch dashboards and alarms

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

### Configuration Schema

Pattern 2 supports the following configuration options:

- **OCR Configuration**: Backend selection (Textract/Bedrock), DPI settings, image processing
- **Classification**: Method selection, model choice, concurrency settings
- **Extraction**: Model selection, parallel processing configuration
- **Monitoring**: Log levels, retention periods, alert thresholds

See `terraform/modules/pattern-2/locals.tf` for the complete schema definition.

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

## Next Steps

- **Pattern 1 and 3**: Consider refactoring to Terraform following the same modular approach
- **CI/CD Integration**: Add automated testing and deployment pipelines
- **Multi-Environment**: Create environment-specific configurations
- **Module Registry**: Publish module to private Terraform registry if needed