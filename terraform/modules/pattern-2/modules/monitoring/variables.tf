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

# Resources to Monitor
variable "state_machine_arn" {
  description = "ARN of the Step Functions state machine to monitor"
  type        = string
}

variable "lambda_function_arns" {
  description = "Map of Lambda function ARNs"
  type        = map(string)
}

variable "lambda_function_names" {
  description = "Map of Lambda function names"
  type        = map(string)
}

# Monitoring Configuration
variable "execution_time_threshold_ms" {
  description = "Threshold in milliseconds for Lambda execution time alerts"
  type        = number
}

variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}