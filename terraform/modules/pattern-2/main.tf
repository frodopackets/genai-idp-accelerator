# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Pattern 2 Main Module
# ========================================
# This module orchestrates the deployment of Pattern 2 components
# including Lambda functions, Step Functions workflow, monitoring,
# and configuration management.

# ----------------------------------------
# Lambda Functions Module
# ----------------------------------------
module "lambda_functions" {
  source = "./modules/lambda-functions"
  
  stack_name               = var.stack_name
  resource_prefix          = local.resource_prefix
  lambda_function_names    = local.lambda_functions
  log_groups              = local.log_groups
  
  # S3 Buckets
  input_bucket            = var.input_bucket
  configuration_bucket    = var.configuration_bucket
  output_bucket           = var.output_bucket
  working_bucket          = var.working_bucket
  
  # DynamoDB Tables
  tracking_table          = var.tracking_table
  configuration_table     = var.configuration_table
  
  # Security
  customer_managed_key_arn = var.customer_managed_key_arn
  permissions_boundary_arn = var.permissions_boundary_arn
  
  # Lambda Configuration
  lambda_runtime          = var.lambda_runtime
  lambda_timeout          = var.lambda_timeout
  lambda_memory_size      = var.lambda_memory_size
  lambda_vpc_config       = var.lambda_vpc_config
  lambda_reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  code_signing_config_arn = var.code_signing_config_arn
  log_retention_days      = var.log_retention_days
  
  # Environment Variables
  common_env_vars         = local.common_lambda_env_vars
  bedrock_env_vars        = local.bedrock_env_vars
  
  # Feature Flags
  is_assessment_enabled   = var.is_assessment_enabled
  is_summarization_enabled = var.is_summarization_enabled
  
  # AppSync Integration
  appsync_api_arn         = var.appsync_api_arn
  
  tags                    = local.common_tags
}

# ----------------------------------------
# Step Functions Workflow Module
# ----------------------------------------
module "step_functions" {
  source = "./modules/step-functions"
  
  stack_name               = var.stack_name
  resource_prefix          = local.resource_prefix
  state_machine_name       = local.state_machine_name
  
  # Lambda Function ARNs
  ocr_function_arn         = module.lambda_functions.function_arns["ocr"]
  classification_function_arn = module.lambda_functions.function_arns["classification"]
  extraction_function_arn  = module.lambda_functions.function_arns["extraction"]
  assessment_function_arn = module.lambda_functions.function_arns["assessment"]
  summarization_function_arn = module.lambda_functions.function_arns["summarization"]
  process_results_function_arn = module.lambda_functions.function_arns["process_results"]
  
  # Security
  customer_managed_key_arn = var.customer_managed_key_arn
  permissions_boundary_arn = var.permissions_boundary_arn
  
  # Logging
  log_retention_days       = var.log_retention_days
  log_level               = var.log_level
  
  tags                    = local.common_tags
}

# ----------------------------------------
# Monitoring Module
# ----------------------------------------
module "monitoring" {
  source = "./modules/monitoring"
  
  stack_name               = var.stack_name
  resource_prefix          = local.resource_prefix
  
  # Resources to Monitor
  state_machine_arn        = module.step_functions.state_machine_arn
  lambda_function_arns     = module.lambda_functions.function_arns
  lambda_function_names    = module.lambda_functions.function_names
  
  # Monitoring Configuration
  execution_time_threshold_ms = var.execution_time_threshold_ms
  log_retention_days       = var.log_retention_days
  
  tags                    = local.common_tags
}

# ----------------------------------------
# Configuration Management Module
# ----------------------------------------
module "configuration" {
  source = "./modules/configuration"
  
  stack_name               = var.stack_name
  resource_prefix          = local.resource_prefix
  
  # DynamoDB Tables
  configuration_table      = var.configuration_table
  
  # Configuration Schema
  configuration_schema     = local.configuration_schema
  
  # Update Function
  update_configuration_function_arn = var.update_configuration_function_arn
  configuration_default_s3_uri = var.configuration_default_s3_uri
  
  tags                    = local.common_tags
}

# ----------------------------------------
# CloudWatch Log Groups
# ----------------------------------------
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = local.log_groups
  
  name              = each.value
  retention_in_days = var.log_retention_days
  kms_key_id       = var.customer_managed_key_arn
  
  tags = merge(
    local.common_tags,
    {
      Name = each.value
      Type = "LambdaLogs"
    }
  )
}

# ----------------------------------------
# Cognito Authentication Module
# ----------------------------------------
module "cognito" {
  source = "./modules/cognito"
  
  resource_prefix = local.resource_prefix
  
  # Password Policy
  password_policy = var.cognito_password_policy
  
  # MFA and Security
  enable_mfa                = var.enable_mfa
  admin_create_user_only    = var.admin_create_user_only
  advanced_security_mode    = var.cognito_advanced_security_mode
  
  # User Pool Domain
  user_pool_domain = var.cognito_user_pool_domain
  
  # OAuth Configuration
  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls
  
  # Token Validity
  token_validity = var.cognito_token_validity
  
  # Email Configuration
  ses_email_identity   = var.ses_email_identity
  reply_to_email      = var.reply_to_email
  from_email_address  = var.from_email_address
  
  # Integration Configuration
  appsync_api_arn = module.appsync.api_arn
  s3_bucket_arns  = [
    var.input_bucket_arn,
    var.output_bucket_arn,
    var.working_bucket_arn,
    module.web_hosting.web_ui_bucket_arn
  ]
  
  # Admin User
  admin_user_email    = var.admin_user_email
  admin_user_name     = var.admin_user_name
  admin_temp_password = var.admin_temp_password
  
  tags = local.common_tags
}

# ----------------------------------------
# AppSync GraphQL API Module
# ----------------------------------------
module "appsync" {
  source = "./modules/appsync"
  
  resource_prefix = local.resource_prefix
  
  # Cognito Configuration
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_client_id = module.cognito.user_pool_client_id
  
  # DynamoDB Tables
  tracking_table_name    = var.tracking_table
  tracking_table_arn     = var.tracking_table_arn
  configuration_table_name = var.configuration_table
  configuration_table_arn  = var.configuration_table_arn
  
  # Lambda Resolvers
  resolver_functions = local.ui_lambda_functions
  lambda_resolvers   = local.lambda_resolvers
  
  # Configuration  
  log_level       = var.log_level == "INFO" ? "ALL" : var.log_level == "DEBUG" ? "ALL" : "ERROR"
  enable_api_key  = var.enable_appsync_api_key
  
  tags = local.common_tags
}

# ----------------------------------------
# Web Hosting Module (CloudFront + S3)
# ----------------------------------------
module "web_hosting" {
  source = "./modules/web-hosting"
  
  resource_prefix = local.resource_prefix
  
  # S3 Configuration
  force_destroy_bucket       = var.force_destroy_web_bucket
  customer_managed_key_arn   = var.customer_managed_key_arn
  access_logging_bucket      = var.access_logging_bucket
  
  # CloudFront Configuration
  cloudfront_price_class     = var.cloudfront_price_class
  geo_restriction           = var.geo_restriction
  custom_domain             = var.custom_domain
  
  # Application Configuration
  app_name                  = var.app_name
  cognito_user_pool_id      = module.cognito.user_pool_id
  cognito_user_pool_client_id = module.cognito.user_pool_client_id
  cognito_identity_pool_id  = module.cognito.identity_pool_id
  appsync_graphql_endpoint  = module.appsync.graphql_url
  
  # Content Deployment
  deploy_placeholder_content = var.deploy_placeholder_content
  
  tags = local.common_tags
}

# ----------------------------------------
# Configuration Schema Update (handled by configuration module)
# ----------------------------------------
# Schema update is now handled by the configuration module