# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "resource_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "force_destroy_bucket" {
  description = "Force destroy S3 bucket on deletion"
  type        = bool
  default     = false
}

variable "customer_managed_key_arn" {
  description = "ARN of customer managed KMS key for encryption"
  type        = string
  default     = null
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
  description = "Geographic restriction configuration"
  type = object({
    type      = string
    locations = list(string)
  })
  default = null
}

variable "custom_domain" {
  description = "Custom domain configuration"
  type = object({
    domain_name      = string
    certificate_arn  = string
    hosted_zone_id   = string
  })
  default = null
}

variable "app_name" {
  description = "Application name for web content"
  type        = string
  default     = "IDP Pattern 2"
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for web app configuration"
  type        = string
  default     = ""
}

variable "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID for web app configuration"
  type        = string
  default     = ""
}

variable "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID for web app configuration"
  type        = string
  default     = ""
}

variable "appsync_graphql_endpoint" {
  description = "AppSync GraphQL endpoint for web app configuration"
  type        = string
  default     = ""
}

variable "deploy_placeholder_content" {
  description = "Deploy placeholder HTML content"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}