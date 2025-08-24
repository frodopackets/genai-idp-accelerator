# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

locals {
  # Common naming conventions
  resource_prefix = "${var.stack_name}-pattern2"
  
  # Lambda function names
  lambda_functions = {
    ocr             = "${local.resource_prefix}-ocr"
    classification  = "${local.resource_prefix}-classification"
    extraction      = "${local.resource_prefix}-extraction"
    assessment      = "${local.resource_prefix}-assessment"
    summarization   = "${local.resource_prefix}-summarization"
    process_results = "${local.resource_prefix}-process-results"
  }
  
  # Step Functions state machine name
  state_machine_name = "${local.resource_prefix}-workflow"
  
  # CloudWatch log group names
  log_groups = {
    for name, function_name in local.lambda_functions : 
    name => "/aws/lambda/${function_name}"
  }
  
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      ManagedBy   = "Terraform"
      Pattern     = "2"
      StackName   = var.stack_name
      Environment = var.environment
    }
  )
  
  # Bedrock configuration
  has_guardrail_config = var.bedrock_guardrail_id != "" && var.bedrock_guardrail_version != ""
  has_custom_classification_model = var.custom_classification_model_arn != ""
  has_custom_extraction_model = var.custom_extraction_model_arn != ""
  has_permissions_boundary = var.permissions_boundary_arn != ""
  
  # Lambda environment variables (common across all functions)
  common_lambda_env_vars = {
    LOG_LEVEL                = var.log_level
    STACK_NAME              = var.stack_name
    INPUT_BUCKET            = var.input_bucket
    OUTPUT_BUCKET           = var.output_bucket
    WORKING_BUCKET          = var.working_bucket
    CONFIGURATION_BUCKET    = var.configuration_bucket
    TRACKING_TABLE          = var.tracking_table
    CONFIGURATION_TABLE     = var.configuration_table
    KMS_KEY_ARN            = var.customer_managed_key_arn
    APPSYNC_API_URL        = var.appsync_api_url
    IS_SUMMARIZATION_ENABLED = tostring(var.is_summarization_enabled)
    IS_ASSESSMENT_ENABLED   = tostring(var.is_assessment_enabled)
  }
  
  # Bedrock-specific environment variables
  bedrock_env_vars = merge(
    local.has_guardrail_config ? {
      BEDROCK_GUARDRAIL_ID      = var.bedrock_guardrail_id
      BEDROCK_GUARDRAIL_VERSION = var.bedrock_guardrail_version
    } : {},
    local.has_custom_classification_model ? {
      CUSTOM_CLASSIFICATION_MODEL_ARN = var.custom_classification_model_arn
    } : {},
    local.has_custom_extraction_model ? {
      CUSTOM_EXTRACTION_MODEL_ARN = var.custom_extraction_model_arn
    } : {}
  )
  
  # Configuration schema for Pattern 2
  configuration_schema = {
    type = "object"
    required = [
      "notes",
      "classes",
      "classification",
      "extraction"
    ]
    properties = {
      notes = {
        order       = 0
        type        = "string"
        description = "Notes"
      }
      ocr = {
        order        = 1
        type         = "object"
        sectionLabel = "OCR Configuration"
        properties = {
          backend = {
            order       = 0
            type        = "string"
            description = "OCR backend to use"
            enum        = ["textract", "bedrock"]
            default     = "textract"
          }
          bedrockModel = {
            order       = 1
            type        = "string"
            description = "Bedrock model for OCR (when backend is bedrock)"
            enum = [
              "anthropic.claude-3-5-sonnet-20241022-v2:0",
              "anthropic.claude-3-5-haiku-20241022-v1:0",
              "us.amazon.nova-pro-v1:0",
              "us.amazon.nova-lite-v1:0"
            ]
            default = "us.amazon.nova-lite-v1:0"
          }
          dpi = {
            order       = 2
            type        = "integer"
            description = "DPI for PDF to image conversion"
            minimum     = 150
            maximum     = 300
            default     = 200
          }
          maxImageSize = {
            order       = 3
            type        = "integer"
            description = "Maximum image size in pixels"
            minimum     = 1000
            maximum     = 5000
            default     = 2048
          }
        }
      }
      classes = {
        order       = 2
        type        = "array"
        description = "Document classes for classification"
        items = {
          type = "string"
        }
      }
      classification = {
        order        = 3
        type         = "object"
        sectionLabel = "Classification Configuration"
        properties = {
          method = {
            order       = 0
            type        = "string"
            description = "Classification method"
            enum        = ["multimodalPageLevelClassification", "textbasedHolisticClassification"]
            default     = "multimodalPageLevelClassification"
          }
          model = {
            order       = 1
            type        = "string"
            description = "Bedrock model for classification"
            enum = [
              "anthropic.claude-3-5-sonnet-20241022-v2:0",
              "anthropic.claude-3-5-haiku-20241022-v1:0",
              "us.amazon.nova-pro-v1:0",
              "us.amazon.nova-lite-v1:0"
            ]
            default = "anthropic.claude-3-5-haiku-20241022-v1:0"
          }
          maxConcurrentPages = {
            order       = 2
            type        = "integer"
            description = "Maximum concurrent pages to process"
            minimum     = 1
            maximum     = 20
            default     = 10
          }
        }
      }
      extraction = {
        order        = 4
        type         = "object"
        sectionLabel = "Extraction Configuration"
        properties = {
          model = {
            order       = 0
            type        = "string"
            description = "Bedrock model for extraction"
            enum = [
              "anthropic.claude-3-5-sonnet-20241022-v2:0",
              "anthropic.claude-3-5-haiku-20241022-v1:0",
              "us.amazon.nova-pro-v1:0",
              "us.amazon.nova-lite-v1:0"
            ]
            default = "anthropic.claude-3-5-sonnet-20241022-v2:0"
          }
          maxConcurrentSections = {
            order       = 1
            type        = "integer"
            description = "Maximum concurrent sections to process"
            minimum     = 1
            maximum     = 10
            default     = 5
          }
        }
      }
    }
  }
}