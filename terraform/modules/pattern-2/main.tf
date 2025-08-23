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
# Configuration Schema Update (handled by configuration module)
# ----------------------------------------
# Schema update is now handled by the configuration module