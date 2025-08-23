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

variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
}

# Lambda Function ARNs
variable "ocr_function_arn" {
  description = "ARN of the OCR Lambda function"
  type        = string
}

variable "classification_function_arn" {
  description = "ARN of the Classification Lambda function"
  type        = string
}

variable "extraction_function_arn" {
  description = "ARN of the Extraction Lambda function"
  type        = string
}

variable "process_results_function_arn" {
  description = "ARN of the Process Results Lambda function"
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

# Logging
variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
}

variable "log_level" {
  description = "Logging level"
  type        = string
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}