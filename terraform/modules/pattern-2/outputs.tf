# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Module Outputs
# ========================================

# Step Functions Outputs
output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = module.step_functions.state_machine_arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = module.step_functions.state_machine_name
}

output "state_machine_url" {
  description = "Console URL for the Step Functions state machine"
  value       = module.step_functions.state_machine_url
}

# Lambda Function Outputs
output "lambda_function_arns" {
  description = "Map of Lambda function ARNs"
  value       = module.lambda_functions.function_arns
}

output "lambda_function_names" {
  description = "Map of Lambda function names"
  value       = module.lambda_functions.function_names
}

output "lambda_log_groups" {
  description = "Map of CloudWatch log group names for Lambda functions"
  value       = { for k, v in aws_cloudwatch_log_group.lambda_logs : k => v.name }
}

# Monitoring Outputs
output "dashboard_url" {
  description = "CloudWatch dashboard URL for Pattern 2 monitoring"
  value       = module.monitoring.dashboard_url
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}

output "alarm_arns" {
  description = "Map of CloudWatch alarm ARNs"
  value       = module.monitoring.alarm_arns
}

# Configuration Outputs
output "configuration_schema" {
  description = "Pattern 2 configuration schema"
  value       = local.configuration_schema
}

output "configuration_schema_json" {
  description = "Pattern 2 configuration schema as JSON string"
  value       = jsonencode(local.configuration_schema)
}

# Resource Information
output "resource_prefix" {
  description = "Resource naming prefix used for all Pattern 2 resources"
  value       = local.resource_prefix
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "tags" {
  description = "Tags applied to all resources"
  value       = local.common_tags
}

# Feature Flags
output "features_enabled" {
  description = "Map of enabled features"
  value = {
    summarization = var.is_summarization_enabled
    assessment    = var.is_assessment_enabled
    guardrails    = local.has_guardrail_config
    custom_models = {
      classification = local.has_custom_classification_model
      extraction     = local.has_custom_extraction_model
    }
  }
}

# Integration Points
output "integration_endpoints" {
  description = "Integration endpoints for Pattern 2"
  value = {
    input_bucket         = var.input_bucket
    output_bucket        = var.output_bucket
    configuration_bucket = var.configuration_bucket
    tracking_table       = var.tracking_table
    configuration_table  = var.configuration_table
  }
}