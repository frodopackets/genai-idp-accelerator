# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

variable "resource_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length              = number
    require_lowercase           = bool
    require_numbers            = bool
    require_symbols            = bool
    require_uppercase          = bool
    temp_password_validity_days = number
  })
  default = {
    minimum_length              = 8
    require_lowercase           = true
    require_numbers            = true
    require_symbols            = true
    require_uppercase          = true
    temp_password_validity_days = 7
  }
}

variable "enable_mfa" {
  description = "Enable multi-factor authentication"
  type        = bool
  default     = false
}

variable "admin_create_user_only" {
  description = "Only allow administrators to create users"
  type        = bool
  default     = true
}

variable "invite_email_template" {
  description = "Email template for user invitations"
  type = object({
    message = string
    subject = string
  })
  default = {
    message = "Your username is {username} and temporary password is {####}"
    subject = "Your temporary password"
  }
}

variable "invite_sms_template" {
  description = "SMS template for user invitations"
  type        = string
  default     = "Your username is {username} and temporary password is {####}"
}

variable "device_challenge_required" {
  description = "Require device challenge on new devices"
  type        = bool
  default     = false
}

variable "device_remembered_on_prompt" {
  description = "Device only remembered on user prompt"
  type        = bool
  default     = true
}

variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "OFF"
  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED."
  }
}

variable "user_pool_domain" {
  description = "Domain name for the user pool (will be prefixed with resource_prefix)"
  type        = string
  default     = null
}

variable "callback_urls" {
  description = "List of allowed callback URLs for the client"
  type        = list(string)
  default     = ["http://localhost:3000/", "https://localhost:3000/"]
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the client"
  type        = list(string)
  default     = ["http://localhost:3000/", "https://localhost:3000/"]
}

variable "token_validity" {
  description = "Token validity periods"
  type = object({
    access_token_hours   = number
    id_token_hours       = number
    refresh_token_days   = number
  })
  default = {
    access_token_hours   = 1
    id_token_hours       = 1
    refresh_token_days   = 30
  }
}

variable "ses_email_identity" {
  description = "SES verified email identity for sending emails"
  type        = string
  default     = null
}

variable "reply_to_email" {
  description = "Reply-to email address"
  type        = string
  default     = null
}

variable "from_email_address" {
  description = "From email address"
  type        = string
  default     = null
}

variable "appsync_api_arn" {
  description = "AppSync API ARN for IAM policies"
  type        = string
  default     = null
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs for user access"
  type        = list(string)
  default     = []
}

variable "admin_user_email" {
  description = "Admin user email address (optional)"
  type        = string
  default     = null
}

variable "admin_user_name" {
  description = "Admin user name (optional)"
  type        = string
  default     = null
}

variable "admin_temp_password" {
  description = "Admin user temporary password"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}