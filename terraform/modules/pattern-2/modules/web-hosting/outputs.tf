# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "web_ui_bucket_name" {
  description = "S3 bucket name for web UI"
  value       = aws_s3_bucket.web_ui.id
}

output "web_ui_bucket_arn" {
  description = "S3 bucket ARN for web UI"
  value       = aws_s3_bucket.web_ui.arn
}

output "web_ui_bucket_domain_name" {
  description = "S3 bucket domain name for web UI"
  value       = aws_s3_bucket.web_ui.bucket_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.web_ui.id
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.web_ui.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.web_ui.domain_name
}

output "website_url" {
  description = "Website URL"
  value       = var.custom_domain != null ? "https://${var.custom_domain.domain_name}" : "https://${aws_cloudfront_distribution.web_ui.domain_name}"
}

output "origin_access_identity_arn" {
  description = "CloudFront Origin Access Identity ARN"
  value       = aws_cloudfront_origin_access_identity.web_ui_oai.iam_arn
}