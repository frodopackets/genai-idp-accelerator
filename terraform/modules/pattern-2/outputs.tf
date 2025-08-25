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

# ========================================
# UI Infrastructure Outputs
# ========================================

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.cognito.user_pool_client_id
}

output "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = module.cognito.identity_pool_id
}

output "cognito_user_pool_domain" {
  description = "Cognito User Pool domain"
  value       = module.cognito.user_pool_domain
}

# AppSync Outputs
output "appsync_api_id" {
  description = "AppSync API ID"
  value       = module.appsync.api_id
}

output "appsync_graphql_url" {
  description = "AppSync GraphQL endpoint URL"
  value       = module.appsync.graphql_url
}

output "appsync_api_key" {
  description = "AppSync API Key (if enabled)"
  value       = module.appsync.api_key
  sensitive   = true
}

# Web Hosting Outputs
output "website_url" {
  description = "Website URL"
  value       = module.web_hosting.website_url
}

output "web_ui_bucket_name" {
  description = "S3 bucket name for web UI"
  value       = module.web_hosting.web_ui_bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.web_hosting.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.web_hosting.cloudfront_domain_name
}

# UI Configuration Summary
output "ui_configuration" {
  description = "Complete UI configuration for React app"
  value = {
    aws_region              = data.aws_region.current.name
    cognito_region          = data.aws_region.current.name
    user_pool_id           = module.cognito.user_pool_id
    user_pool_client_id    = module.cognito.user_pool_client_id
    identity_pool_id       = module.cognito.identity_pool_id
    graphql_endpoint       = module.appsync.graphql_url
    website_url            = module.web_hosting.website_url
    web_ui_bucket         = module.web_hosting.web_ui_bucket_name
    cloudfront_domain     = module.web_hosting.cloudfront_domain_name
  }
}

# Deployment Instructions
output "deployment_instructions" {
  description = "Instructions for completing the UI deployment"
  value = {
    backend_status = "✅ Backend infrastructure deployed successfully"
    frontend_status = "❌ React application requires separate build and deployment"
    next_steps = [
      "1. Build the React application from /src/ui/ directory",
      "2. Configure React app with the UI configuration values above",
      "3. Deploy built assets to S3 bucket: ${module.web_hosting.web_ui_bucket_name}",
      "4. Invalidate CloudFront cache: ${module.web_hosting.cloudfront_distribution_id}",
      "5. Access the application at: ${module.web_hosting.website_url}"
    ]
    ui_config_file = "Save the ui_configuration output to a .env file for React app"
  }
}

# Data Sources
data "aws_region" "current" {}