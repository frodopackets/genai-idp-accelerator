# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Cognito Authentication Submodule
# ========================================
# This submodule manages Cognito User Pool and Identity Pool for Pattern 2 UI:
# - User Pool with password policies and MFA
# - User Pool Client for web app
# - Identity Pool for AWS resource access
# - Admin user creation

# ----------------------------------------
# Data Sources
# ----------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ----------------------------------------
# Cognito User Pool
# ----------------------------------------
resource "aws_cognito_user_pool" "pattern2_pool" {
  name = "${var.resource_prefix}-user-pool"
  
  # Password Policy
  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    require_lowercase                = var.password_policy.require_lowercase
    require_numbers                  = var.password_policy.require_numbers
    require_symbols                  = var.password_policy.require_symbols
    require_uppercase                = var.password_policy.require_uppercase
    temporary_password_validity_days = var.password_policy.temp_password_validity_days
  }
  
  # Auto-verified attributes
  auto_verified_attributes = ["email"]
  
  # Attributes that can be used as username
  username_attributes = ["email"]
  
  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  
  # User attribute configuration
  schema {
    attribute_data_type = "String"
    name               = "email"
    required           = true
    mutable            = true
    
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
  
  schema {
    attribute_data_type = "String"
    name               = "name"
    required           = true
    mutable            = true
    
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
  
  # Email configuration
  dynamic "email_configuration" {
    for_each = var.ses_email_identity != null ? [1] : []
    content {
      email_sending_account  = "DEVELOPER"
      source_arn            = "arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/${var.ses_email_identity}"
      reply_to_email_address = var.reply_to_email
      from_email_address     = var.from_email_address
    }
  }
  
  # MFA configuration
  mfa_configuration = var.enable_mfa ? "ON" : "OFF"
  
  dynamic "software_token_mfa_configuration" {
    for_each = var.enable_mfa ? [1] : []
    content {
      enabled = true
    }
  }
  
  # Admin create user configuration
  admin_create_user_config {
    allow_admin_create_user_only = var.admin_create_user_only
    
    invite_message_template {
      email_message = var.invite_email_template.message
      email_subject = var.invite_email_template.subject
      sms_message   = var.invite_sms_template
    }
  }
  
  # Device configuration
  device_configuration {
    challenge_required_on_new_device      = var.device_challenge_required
    device_only_remembered_on_user_prompt = var.device_remembered_on_prompt
  }
  
  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-user-pool"
      Type = "CognitoUserPool"
    }
  )
}

# ----------------------------------------
# User Pool Domain
# ----------------------------------------
resource "aws_cognito_user_pool_domain" "pattern2_domain" {
  count  = var.user_pool_domain != null ? 1 : 0
  domain = "${var.resource_prefix}-${var.user_pool_domain}"
  user_pool_id = aws_cognito_user_pool.pattern2_pool.id
}

# ----------------------------------------
# User Pool Client
# ----------------------------------------
resource "aws_cognito_user_pool_client" "pattern2_client" {
  name         = "${var.resource_prefix}-client"
  user_pool_id = aws_cognito_user_pool.pattern2_pool.id
  
  generate_secret = false
  
  # OAuth configuration
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls
  
  supported_identity_providers = ["COGNITO"]
  
  # Token validity
  access_token_validity  = var.token_validity.access_token_hours
  id_token_validity      = var.token_validity.id_token_hours
  refresh_token_validity = var.token_validity.refresh_token_days
  
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
  
  # Security settings
  prevent_user_existence_errors = "ENABLED"
  
  # Read and write attributes
  read_attributes  = ["email", "name", "email_verified"]
  write_attributes = ["email", "name"]
  
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# ----------------------------------------
# Identity Pool
# ----------------------------------------
resource "aws_cognito_identity_pool" "pattern2_identity_pool" {
  identity_pool_name               = "${var.resource_prefix}-identity-pool"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false
  
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.pattern2_client.id
    provider_name           = aws_cognito_user_pool.pattern2_pool.endpoint
    server_side_token_check = true
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-identity-pool"
      Type = "CognitoIdentityPool"
    }
  )
}

# ----------------------------------------
# Identity Pool Role Attachment
# ----------------------------------------
resource "aws_cognito_identity_pool_roles_attachment" "pattern2_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.pattern2_identity_pool.id
  
  roles = {
    "authenticated"   = aws_iam_role.cognito_authenticated.arn
    "unauthenticated" = aws_iam_role.cognito_unauthenticated.arn
  }
  
  role_mapping {
    identity_provider         = "${aws_cognito_user_pool.pattern2_pool.endpoint}:${aws_cognito_user_pool_client.pattern2_client.id}"
    ambiguous_role_resolution = "AuthenticatedRole"
    type                      = "Token"
  }
}

# ----------------------------------------
# IAM Roles for Identity Pool
# ----------------------------------------
resource "aws_iam_role" "cognito_authenticated" {
  name = "${var.resource_prefix}-cognito-authenticated-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.pattern2_identity_pool.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-cognito-authenticated-role"
    }
  )
}

resource "aws_iam_role" "cognito_unauthenticated" {
  name = "${var.resource_prefix}-cognito-unauthenticated-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.pattern2_identity_pool.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-cognito-unauthenticated-role"
    }
  )
}

# ----------------------------------------
# IAM Policies for Authenticated Users
# ----------------------------------------
resource "aws_iam_role_policy" "cognito_authenticated_policy" {
  name = "${var.resource_prefix}-cognito-authenticated-policy"
  role = aws_iam_role.cognito_authenticated.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "cognito-identity:*",
          "cognito-sync:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "appsync:GraphQL"
        ]
        Resource = var.appsync_api_arn != null ? [var.appsync_api_arn] : ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          for bucket in var.s3_bucket_arns : "${bucket}/*"
        ]
      }
    ], var.parameter_store_arn != null ? [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [var.parameter_store_arn]
      }
    ] : [])
  })
}

resource "aws_iam_role_policy" "cognito_unauthenticated_policy" {
  name = "${var.resource_prefix}-cognito-unauthenticated-policy"
  role = aws_iam_role.cognito_unauthenticated.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
      }
    ]
  })
}

# ----------------------------------------
# Admin User (optional)
# ----------------------------------------
resource "aws_cognito_user" "admin_user" {
  count          = var.admin_user_email != null ? 1 : 0
  user_pool_id   = aws_cognito_user_pool.pattern2_pool.id
  username       = var.admin_user_email
  message_action = "SUPPRESS"
  
  attributes = {
    email           = var.admin_user_email
    name           = var.admin_user_name != null ? var.admin_user_name : "Admin User"
    email_verified = true
  }
  
  temporary_password = var.admin_temp_password
  
  lifecycle {
    ignore_changes = [temporary_password]
  }
}