# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "stack_name" {
  description = "Name of the stack"
  type        = string
}

variable "resource_prefix" {
  description = "Resource naming prefix"
  type        = string
}

variable "lambda_function_names" {
  description = "Map of Lambda function names"
  type        = map(string)
}

variable "log_groups" {
  description = "Map of CloudWatch log group names"
  type        = map(string)
}

# S3 Buckets
variable "input_bucket" {
  description = "S3 bucket for input documents"
  type        = string
}

variable "configuration_bucket" {
  description = "S3 bucket for configuration files"
  type        = string
}

variable "output_bucket" {
  description = "S3 bucket for output results"
  type        = string
}

variable "working_bucket" {
  description = "S3 bucket for temporary working files"
  type        = string
}

# DynamoDB Tables
variable "tracking_table" {
  description = "DynamoDB table for tracking"
  type        = string
}

variable "configuration_table" {
  description = "DynamoDB table for configuration"
  type        = string
}

# Security
variable "customer_managed_key_arn" {
  description = "KMS key ARN"
  type        = string
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary ARN"
  type        = string
  default     = ""
}

# Lambda Configuration
variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "lambda_vpc_config" {
  description = "VPC configuration for Lambda functions"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
}

variable "lambda_reserved_concurrent_executions" {
  description = "Reserved concurrent executions for Lambda functions (security best practice)"
  type        = number
  default     = 100
  
  validation {
    condition     = var.lambda_reserved_concurrent_executions >= 0
    error_message = "Reserved concurrent executions must be 0 or positive."
  }
}

variable "code_signing_config_arn" {
  description = "ARN of the Code Signing Config for Lambda functions (security best practice)"
  type        = string
  default     = ""
}

# Environment Variables
variable "common_env_vars" {
  description = "Common environment variables for all Lambda functions"
  type        = map(string)
}

variable "bedrock_env_vars" {
  description = "Bedrock-specific environment variables"
  type        = map(string)
}

# AppSync
variable "appsync_api_arn" {
  description = "AppSync API ARN"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}