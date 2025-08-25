# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "resource_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for authentication"
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  type        = string
}

variable "tracking_table_name" {
  description = "DynamoDB tracking table name"
  type        = string
}

variable "tracking_table_arn" {
  description = "DynamoDB tracking table ARN"
  type        = string
}

variable "configuration_table_name" {
  description = "DynamoDB configuration table name"
  type        = string
}

variable "configuration_table_arn" {
  description = "DynamoDB configuration table ARN"
  type        = string
}

variable "resolver_functions" {
  description = "Map of resolver function names to ARNs"
  type        = map(string)
  default     = {}
}

variable "lambda_resolvers" {
  description = "Map of lambda resolver configurations"
  type = map(object({
    field = string
    type  = string
  }))
  default = {}
}

variable "log_level" {
  description = "AppSync log level"
  type        = string
  default     = "ERROR"
  validation {
    condition     = contains(["NONE", "ERROR", "ALL"], var.log_level)
    error_message = "Log level must be NONE, ERROR, or ALL."
  }
}

variable "enable_api_key" {
  description = "Enable API key for development/testing"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}