# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "stack_name" {
  description = "Name of the stack"
  type        = string
  default     = "idp-pattern2-example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "enable_summarization" {
  description = "Enable document summarization"
  type        = bool
  default     = true
}

variable "enable_assessment" {
  description = "Enable extraction confidence assessment"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days (minimum 365 for security compliance)"
  type        = number
  default     = 365
}

variable "log_level" {
  description = "Logging level"
  type        = string
  default     = "INFO"
}

variable "enable_cross_region_replication" {
  description = "Enable cross-region replication for S3 buckets (security best practice)"
  type        = bool
  default     = false
}

variable "replication_destination_region" {
  description = "Destination region for S3 cross-region replication"
  type        = string
  default     = "us-west-2"
}

# ========================================
# UI Infrastructure Variables
# ========================================

variable "admin_user_email" {
  description = "Admin user email address for Cognito (optional)"
  type        = string
  default     = null
}

variable "admin_user_name" {
  description = "Admin user name for Cognito (optional)"
  type        = string
  default     = "Administrator"
}

variable "admin_temp_password" {
  description = "Admin user temporary password"
  type        = string
  default     = null
  sensitive   = true
}

variable "enable_custom_domain" {
  description = "Enable custom domain for web UI"
  type        = bool
  default     = false
}

variable "custom_domain" {
  description = "Custom domain name for web UI (e.g., idp.example.com)"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain (must be in us-east-1 for CloudFront)"
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for custom domain"
  type        = string
  default     = null
}