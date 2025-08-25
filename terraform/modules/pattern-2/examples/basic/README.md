# Pattern 2 Basic Example

This example demonstrates a basic deployment of the Pattern 2 Terraform module with minimal configuration.

## What This Creates

- KMS key for encryption
- S3 buckets (input, output, working, configuration)
- DynamoDB tables (tracking, configuration)
- Pattern 2 Lambda functions and Step Functions workflow
- CloudWatch dashboard and monitoring

## Usage

1. **Clone the repository and navigate to this example:**
   ```bash
   cd terraform/modules/pattern-2/examples/basic
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review and modify variables (optional):**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your desired values
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Configuration

### Required Variables
- `aws_region` - AWS region for deployment (default: us-east-1)
- `stack_name` - Name of the stack (default: idp-pattern2-example)

### Optional Variables
- `environment` - Environment name (default: dev)
- `enable_summarization` - Enable document summarization (default: true)
- `enable_assessment` - Enable extraction confidence assessment (default: false)
- `log_retention_days` - CloudWatch log retention in days (default: 30)
- `log_level` - Logging level (default: INFO)

### Example terraform.tfvars
```hcl
aws_region            = "us-west-2"
stack_name            = "my-idp-pattern2"
environment           = "production"
enable_summarization  = true
enable_assessment     = false
log_retention_days    = 90
log_level            = "WARN"
```

## Outputs

After deployment, you'll receive:
- `state_machine_arn` - ARN of the Step Functions state machine
- `state_machine_url` - Console URL to view the workflow
- `dashboard_url` - CloudWatch dashboard for monitoring
- `input_bucket` - Name of the input S3 bucket
- `output_bucket` - Name of the output S3 bucket
- `kms_key_arn` - ARN of the KMS key used for encryption

## Testing the Deployment

1. **Upload a test document:**
   ```bash
   aws s3 cp sample-document.pdf s3://$(terraform output -raw input_bucket)/
   ```

2. **Monitor the workflow:**
   - Use the Step Functions console URL from the output
   - Check the CloudWatch dashboard for metrics

3. **View results:**
   ```bash
   aws s3 ls s3://$(terraform output -raw output_bucket)/
   ```

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Access to Amazon Bedrock models (Claude 3.5 Haiku, Claude 3.5 Sonnet, Nova models)

## Required AWS Permissions

Your AWS credentials need permissions for:
- S3 bucket creation and management
- DynamoDB table creation and management
- Lambda function creation and management
- Step Functions state machine creation
- IAM role and policy creation
- KMS key creation and management
- CloudWatch logs and dashboards

## Clean Up

To remove all resources:
```bash
terraform destroy
```

**Note:** This will permanently delete all resources including S3 buckets and their contents.