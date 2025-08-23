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