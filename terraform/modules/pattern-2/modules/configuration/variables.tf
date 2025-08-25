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

# DynamoDB Tables
variable "configuration_table" {
  description = "DynamoDB table for configuration"
  type        = string
}

# Configuration Schema
variable "configuration_schema" {
  description = "Configuration schema for Pattern 2"
  type        = any
}

# Update Function
variable "update_configuration_function_arn" {
  description = "ARN of the Lambda function for updating configuration"
  type        = string
  default     = ""
}

variable "configuration_default_s3_uri" {
  description = "S3 URI for default configuration"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}