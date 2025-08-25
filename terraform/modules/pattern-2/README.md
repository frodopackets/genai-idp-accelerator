# Pattern 2 Terraform Module - Bedrock Classification and Extraction

This Terraform module implements the Pattern 2 IDP workflow that uses Amazon Bedrock with Nova or Claude models for both page classification/grouping and information extraction.

## Architecture Overview

The workflow consists of three main processing steps with an optional assessment step:
1. **OCR processing** using Amazon Textract or Amazon Bedrock
2. **Document classification** using Claude via Amazon Bedrock (with two available methods):
   - Page-level classification: Classifies individual pages and groups them
   - Holistic packet classification: Analyzes multi-document packets to identify document boundaries
3. **Field extraction** using Claude via Amazon Bedrock
4. **Assessment** (optional): Confidence evaluation of extraction results using LLMs

## Module Structure

```
pattern-2/
├── README.md                     # This file
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
    ├── basic/                    # Basic deployment example
    └── complete/                 # Complete deployment with all features
```

## Usage

### Basic Example

```hcl
module "pattern_2" {
  source = "../../modules/pattern-2"

  stack_name                    = "idp-pattern-2"
  input_bucket                  = aws_s3_bucket.input.id
  configuration_bucket          = aws_s3_bucket.config.id
  output_bucket                 = aws_s3_bucket.output.id
  working_bucket                = aws_s3_bucket.working.id
  tracking_table                = aws_dynamodb_table.tracking.name
  configuration_table           = aws_dynamodb_table.config.name
  customer_managed_key_arn      = aws_kms_key.idp.arn
  
  # Optional features
  is_summarization_enabled      = true
  is_assessment_enabled         = false
  
  # AppSync integration
  appsync_api_url              = var.appsync_api_url
  appsync_api_arn              = var.appsync_api_arn
  
  # Monitoring
  log_retention_days           = 30
  log_level                   = "INFO"
  
  tags = {
    Environment = "production"
    Project     = "IDP"
    Pattern     = "2"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| stack_name | Name of the stack | `string` | n/a | yes |
| input_bucket | S3 bucket for input documents | `string` | n/a | yes |
| configuration_bucket | S3 bucket for configuration files | `string` | n/a | yes |
| output_bucket | S3 bucket for output results | `string` | n/a | yes |
| working_bucket | S3 bucket for temporary working files | `string` | n/a | yes |
| tracking_table | DynamoDB table for tracking document processing | `string` | n/a | yes |
| configuration_table | DynamoDB table for configuration management | `string` | n/a | yes |
| customer_managed_key_arn | KMS key ARN for encryption | `string` | n/a | yes |
| log_retention_days | CloudWatch log retention in days | `number` | `30` | no |
| log_level | Logging level for Lambda functions | `string` | `"INFO"` | no |
| is_summarization_enabled | Enable document summarization | `bool` | `true` | no |
| is_assessment_enabled | Enable extraction confidence assessment | `bool` | `false` | no |
| bedrock_guardrail_id | Bedrock Guardrail ID for content filtering | `string` | `""` | no |
| bedrock_guardrail_version | Bedrock Guardrail version | `string` | `""` | no |
| permissions_boundary_arn | IAM permissions boundary ARN | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| state_machine_arn | ARN of the Step Functions state machine |
| lambda_function_arns | Map of Lambda function ARNs |
| dashboard_url | CloudWatch dashboard URL |
| configuration_schema | Pattern 2 configuration schema |

## Submodules

### lambda-functions
Manages all Lambda functions for OCR, classification, extraction, and results processing.

### step-functions
Manages the Step Functions state machine workflow orchestration.

### monitoring
Creates CloudWatch dashboard and custom metrics for monitoring.

### configuration
Manages DynamoDB configuration and schema updates.

## Security Considerations

- All Lambda functions use least-privilege IAM roles
- S3 buckets are encrypted with customer-managed KMS keys
- DynamoDB tables use encryption at rest
- Optional Bedrock Guardrails for content filtering
- Support for IAM permissions boundaries

## Best Practices

- Follow the principle of least privilege for IAM roles
- Use tags for resource organization and cost tracking
- Enable CloudWatch logging and monitoring
- Regularly review and update Bedrock model versions
- Test configuration changes in non-production environments first

## License

Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0