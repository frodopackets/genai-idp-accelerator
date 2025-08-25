# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.pattern2_pool.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.pattern2_pool.arn
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.pattern2_client.id
}

output "user_pool_client_secret" {
  description = "Cognito User Pool Client Secret (if generated)"
  value       = aws_cognito_user_pool_client.pattern2_client.client_secret
  sensitive   = true
}

output "user_pool_endpoint" {
  description = "Cognito User Pool endpoint"
  value       = aws_cognito_user_pool.pattern2_pool.endpoint
}

output "user_pool_domain" {
  description = "Cognito User Pool domain"
  value       = var.user_pool_domain != null ? aws_cognito_user_pool_domain.pattern2_domain[0].domain : null
}

output "identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = aws_cognito_identity_pool.pattern2_identity_pool.id
}

output "identity_pool_arn" {
  description = "Cognito Identity Pool ARN"
  value       = aws_cognito_identity_pool.pattern2_identity_pool.arn
}

output "authenticated_role_arn" {
  description = "IAM role ARN for authenticated users"
  value       = aws_iam_role.cognito_authenticated.arn
}

output "unauthenticated_role_arn" {
  description = "IAM role ARN for unauthenticated users"
  value       = aws_iam_role.cognito_unauthenticated.arn
}