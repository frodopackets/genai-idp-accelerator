# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Core Infrastructure Variables
variable "stack_name" {
  description = "Name of the stack"
  type        = string
  validation {
    condition     = length(var.stack_name) > 0
    error_message = "Stack name must not be empty."
  }
}

# S3 Bucket Variables
variable "input_bucket" {
  description = "S3 bucket name for input documents"
  type        = string
}

variable "configuration_bucket" {
  description = "S3 bucket name for configuration files"
  type        = string
}

variable "output_bucket" {
  description = "S3 bucket name for output results"
  type        = string
}

variable "working_bucket" {
  description = "S3 bucket name for temporary working files"
  type        = string
}

# DynamoDB Table Variables
variable "tracking_table" {
  description = "DynamoDB table name for tracking document processing"
  type        = string
}

variable "configuration_table" {
  description = "DynamoDB table name for configuration management"
  type        = string
}

# Security Variables
variable "customer_managed_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:kms:", var.customer_managed_key_arn))
    error_message = "Must be a valid KMS key ARN."
  }
}

variable "permissions_boundary_arn" {
  description = "ARN of an existing IAM Permissions Boundary policy to attach to all IAM roles"
  type        = string
  default     = ""
  validation {
    condition     = var.permissions_boundary_arn == "" || can(regex("^arn:aws:iam::[0-9]{12}:policy/.+", var.permissions_boundary_arn))
    error_message = "Must be empty or a valid IAM policy ARN."
  }
}

# Logging and Monitoring Variables
variable "log_retention_days" {
  description = "CloudWatch log retention in days (minimum 365 days for security compliance)"
  type        = number
  default     = 365
  validation {
    condition     = contains([365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be at least 365 days for security compliance. Valid values: [365, 400, 545, 731, 1827, 3653]."
  }
}

variable "log_level" {
  description = "Default logging level for all Lambda functions"
  type        = string
  default     = "INFO"
  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"], var.log_level)
    error_message = "Log level must be one of: DEBUG, INFO, WARN, ERROR, CRITICAL."
  }
}

variable "execution_time_threshold_ms" {
  description = "Threshold in milliseconds for Lambda execution time alerts"
  type        = number
  default     = 30000
  validation {
    condition     = var.execution_time_threshold_ms > 0
    error_message = "Execution time threshold must be positive."
  }
}

# AppSync Integration Variables
variable "appsync_api_url" {
  description = "The AppSync API URL for status updates"
  type        = string
  default     = ""
}

variable "appsync_api_arn" {
  description = "The AppSync API ARN for IAM permissions"
  type        = string
  default     = ""
}

# Feature Toggle Variables
variable "is_summarization_enabled" {
  description = "Enable or disable document summarization functionality"
  type        = bool
  default     = true
}

variable "is_assessment_enabled" {
  description = "Enable or disable extraction confidence assessment functionality"
  type        = bool
  default     = false
}

# Bedrock Configuration Variables
variable "bedrock_guardrail_id" {
  description = "Optionally provide the Id (not name) of an existing Bedrock Guardrail"
  type        = string
  default     = ""
}

variable "bedrock_guardrail_version" {
  description = "If you provided a Bedrock Guardrail Id above, provide the corresponding version"
  type        = string
  default     = ""
}

variable "custom_classification_model_arn" {
  description = "ARN of a custom classification model (optional)"
  type        = string
  default     = ""
  validation {
    condition     = var.custom_classification_model_arn == "" || can(regex("^arn:aws:", var.custom_classification_model_arn))
    error_message = "Must be empty or a valid ARN."
  }
}

variable "custom_extraction_model_arn" {
  description = "ARN of a custom extraction model (optional)"
  type        = string
  default     = ""
  validation {
    condition     = var.custom_extraction_model_arn == "" || can(regex("^arn:aws:", var.custom_extraction_model_arn))
    error_message = "Must be empty or a valid ARN."
  }
}

# Configuration Variables
variable "configuration_default_s3_uri" {
  description = "S3 URI (s3://bucket/path/config.json) to import default configuration from S3"
  type        = string
  default     = ""
  validation {
    condition     = var.configuration_default_s3_uri == "" || can(regex("^s3://", var.configuration_default_s3_uri))
    error_message = "Must be empty or a valid S3 URI starting with s3://."
  }
}

variable "update_configuration_function_arn" {
  description = "ARN of the Lambda function for updating configuration"
  type        = string
  default     = ""
}

# Lambda Configuration Variables
variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.11"
  validation {
    condition     = contains(["python3.9", "python3.10", "python3.11", "python3.12"], var.lambda_runtime)
    error_message = "Lambda runtime must be a supported Python version."
  }
}

variable "lambda_vpc_config" {
  description = "VPC configuration for Lambda functions (recommended for security)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "lambda_reserved_concurrent_executions" {
  description = "Reserved concurrent executions for Lambda functions (security best practice)"
  type        = number
  default     = 100
  
  validation {
    condition     = var.lambda_reserved_concurrent_executions >= 0
    error_message = "Reserved concurrent executions must be 0 or positive."
  }
}

variable "code_signing_config_arn" {
  description = "ARN of the Code Signing Config for Lambda functions (security best practice)"
  type        = string
  default     = ""
}

variable "lambda_timeout" {
  description = "Default Lambda function timeout in seconds"
  type        = number
  default     = 900
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Default Lambda function memory size in MB"
  type        = number
  default     = 3008
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240 && var.lambda_memory_size % 64 == 0
    error_message = "Lambda memory size must be between 128 and 10240 MB in 64 MB increments."
  }
}

# Resource Tagging
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

# ========================================
# UI Infrastructure Variables
# ========================================

# Cognito Authentication Variables
variable "cognito_password_policy" {
  description = "Cognito password policy configuration"
  type = object({
    minimum_length              = number
    require_lowercase           = bool
    require_numbers            = bool
    require_symbols            = bool
    require_uppercase          = bool
    temp_password_validity_days = number
  })
  default = {
    minimum_length              = 8
    require_lowercase           = true
    require_numbers            = true
    require_symbols            = true
    require_uppercase          = true
    temp_password_validity_days = 7
  }
}

variable "enable_mfa" {
  description = "Enable multi-factor authentication for Cognito"
  type        = bool
  default     = false
}

variable "admin_create_user_only" {
  description = "Only allow administrators to create users"
  type        = bool
  default     = true
}

variable "cognito_advanced_security_mode" {
  description = "Cognito advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "OFF"
  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.cognito_advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED."
  }
}

variable "cognito_user_pool_domain" {
  description = "Domain name for the Cognito user pool"
  type        = string
  default     = null
}

variable "cognito_callback_urls" {
  description = "List of allowed callback URLs for Cognito client"
  type        = list(string)
  default     = ["http://localhost:3000/", "https://localhost:3000/"]
}

variable "cognito_logout_urls" {
  description = "List of allowed logout URLs for Cognito client"
  type        = list(string)
  default     = ["http://localhost:3000/", "https://localhost:3000/"]
}

variable "cognito_token_validity" {
  description = "Token validity periods for Cognito"
  type = object({
    access_token_hours   = number
    id_token_hours       = number
    refresh_token_days   = number
  })
  default = {
    access_token_hours   = 1
    id_token_hours       = 1
    refresh_token_days   = 30
  }
}

# Email Configuration
variable "ses_email_identity" {
  description = "SES verified email identity for sending emails"
  type        = string
  default     = null
}

variable "reply_to_email" {
  description = "Reply-to email address for Cognito emails"
  type        = string
  default     = null
}

variable "from_email_address" {
  description = "From email address for Cognito emails"
  type        = string
  default     = null
}

# Admin User Configuration
variable "admin_user_email" {
  description = "Admin user email address (optional)"
  type        = string
  default     = null
}

variable "admin_user_name" {
  description = "Admin user name (optional)"
  type        = string
  default     = null
}

variable "admin_temp_password" {
  description = "Admin user temporary password"
  type        = string
  default     = null
  sensitive   = true
}

# AppSync Configuration
variable "enable_appsync_api_key" {
  description = "Enable AppSync API key for development/testing"
  type        = bool
  default     = false
}

# Web Hosting Configuration
variable "app_name" {
  description = "Application name for web UI"
  type        = string
  default     = "IDP Pattern 2"
}

variable "force_destroy_web_bucket" {
  description = "Force destroy web UI S3 bucket on deletion"
  type        = bool
  default     = false
}

variable "access_logging_bucket" {
  description = "S3 bucket for access logging"
  type        = string
  default     = null
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be PriceClass_All, PriceClass_200, or PriceClass_100."
  }
}

variable "geo_restriction" {
  description = "Geographic restriction configuration for CloudFront"
  type = object({
    type      = string
    locations = list(string)
  })
  default = null
}

variable "custom_domain" {
  description = "Custom domain configuration for web UI"
  type = object({
    domain_name      = string
    certificate_arn  = string
    hosted_zone_id   = string
  })
  default = null
}

variable "deploy_placeholder_content" {
  description = "Deploy placeholder HTML content to web UI bucket"
  type        = bool
  default     = true
}

# S3 Bucket ARNs (for Cognito IAM policies)
variable "input_bucket_arn" {
  description = "Input S3 bucket ARN"
  type        = string
  default     = ""
}

variable "output_bucket_arn" {
  description = "Output S3 bucket ARN"
  type        = string
  default     = ""
}

variable "working_bucket_arn" {
  description = "Working S3 bucket ARN"
  type        = string
  default     = ""
}

variable "tracking_table_arn" {
  description = "Tracking DynamoDB table ARN"
  type        = string
  default     = ""
}

variable "configuration_table_arn" {
  description = "Configuration DynamoDB table ARN"
  type        = string
  default     = ""
}