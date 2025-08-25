# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = module.pattern_2.state_machine_arn
}

output "state_machine_url" {
  description = "Console URL for the Step Functions state machine"
  value       = module.pattern_2.state_machine_url
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.pattern_2.dashboard_url
}

output "input_bucket" {
  description = "Input S3 bucket name"
  value       = aws_s3_bucket.input.id
}

output "output_bucket" {
  description = "Output S3 bucket name"
  value       = aws_s3_bucket.output.id
}

output "kms_key_arn" {
  description = "KMS key ARN used for encryption"
  value       = aws_kms_key.idp.arn
}

# ========================================
# UI Infrastructure Outputs
# ========================================

output "website_url" {
  description = "Website URL for the Pattern 2 UI"
  value       = module.pattern_2.website_url
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.pattern_2.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.pattern_2.cognito_user_pool_client_id
}

output "appsync_graphql_url" {
  description = "AppSync GraphQL endpoint URL"
  value       = module.pattern_2.appsync_graphql_url
}

output "ui_configuration" {
  description = "Complete UI configuration for React app"
  value       = module.pattern_2.ui_configuration
}

output "deployment_instructions" {
  description = "Instructions for completing the UI deployment"
  value       = module.pattern_2.deployment_instructions
}