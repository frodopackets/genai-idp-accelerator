# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "api_id" {
  description = "AppSync API ID"
  value       = aws_appsync_graphql_api.pattern2_api.id
}

output "api_arn" {
  description = "AppSync API ARN"
  value       = aws_appsync_graphql_api.pattern2_api.arn
}

output "graphql_url" {
  description = "AppSync GraphQL URL"
  value       = aws_appsync_graphql_api.pattern2_api.uris["GRAPHQL"]
}

output "api_key" {
  description = "AppSync API Key (if enabled)"
  value       = var.enable_api_key ? aws_appsync_api_key.pattern2_api_key[0].key : null
  sensitive   = true
}