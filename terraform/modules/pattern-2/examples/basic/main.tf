# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Basic Pattern 2 Deployment Example
# ========================================
# This example demonstrates a basic deployment of Pattern 2
# with minimal configuration.

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Provider for replication destination region
provider "aws" {
  alias  = "replica"
  region = var.replication_destination_region
}

# ----------------------------------------
# Data Sources
# ----------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ----------------------------------------
# KMS Key for Encryption
# ----------------------------------------
resource "aws_kms_key" "idp" {
  description             = "KMS key for IDP Pattern 2 encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow services to use the key"
        Effect = "Allow"
        Principal = {
          Service = [
            "s3.amazonaws.com",
            "lambda.amazonaws.com",
            "states.amazonaws.com",
            "dynamodb.amazonaws.com",
            "logs.amazonaws.com",
            "sns.amazonaws.com",
            "sqs.amazonaws.com",
            "cloudfront.amazonaws.com"
          ]
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow CloudFront to access S3 objects"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.${data.aws_region.current.name}.amazonaws.com"
          }
          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" = "arn:aws:s3:::${var.stack_name}-pattern2-web-ui-${data.aws_caller_identity.current.account_id}/*"
          }
        }
      }
    ]
  })
  
  tags = local.tags
}

resource "aws_kms_alias" "idp" {
  name          = "alias/${var.stack_name}-pattern2"
  target_key_id = aws_kms_key.idp.key_id
}

# ----------------------------------------
# S3 Buckets
# ----------------------------------------
resource "aws_s3_bucket" "input" {
  bucket = "${var.stack_name}-pattern2-input-${data.aws_caller_identity.current.account_id}"
  
  tags = merge(
    local.tags,
    {
      Name = "${var.stack_name}-pattern2-input"
      Type = "Input"
    }
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "input" {
  bucket = aws_s3_bucket.input.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.idp.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "input" {
  bucket = aws_s3_bucket.input.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "input" {
  bucket = aws_s3_bucket.input.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "input" {
  bucket = aws_s3_bucket.input.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["https://${module.pattern_2.website_domain}", "http://localhost:3000", "https://localhost:3000"]
    expose_headers  = ["ETag", "x-amz-request-id"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_logging" "input" {
  bucket = aws_s3_bucket.input.id

  target_bucket = aws_s3_bucket.input.id
  target_prefix = "access-logs/"
}

resource "aws_s3_bucket_notification" "input" {
  bucket = aws_s3_bucket.input.id

  topic {
    topic_arn = aws_sns_topic.s3_events.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_sns_topic_policy.s3_events]
}

resource "aws_s3_bucket_lifecycle_configuration" "input" {
  bucket = aws_s3_bucket.input.id

  rule {
    id     = "input_lifecycle"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Cross-region replication for input bucket (if enabled)
resource "aws_s3_bucket_replication_configuration" "input" {
  count      = var.enable_cross_region_replication ? 1 : 0
  depends_on = [aws_s3_bucket_versioning.input]

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.input.id

  rule {
    id     = "input_replication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.input_replica[0].arn
      storage_class = "STANDARD_IA"

      encryption_configuration {
        replica_kms_key_id = aws_kms_key.replica[0].arn
      }
    }
  }
}

resource "aws_s3_bucket" "output" {
  bucket = "${var.stack_name}-pattern2-output-${data.aws_caller_identity.current.account_id}"
  
  tags = merge(
    local.tags,
    {
      Name = "${var.stack_name}-pattern2-output"
      Type = "Output"
    }
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "output" {
  bucket = aws_s3_bucket.output.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.idp.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "output" {
  bucket = aws_s3_bucket.output.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "output" {
  bucket = aws_s3_bucket.output.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "output" {
  bucket = aws_s3_bucket.output.id

  target_bucket = aws_s3_bucket.output.id
  target_prefix = "access-logs/"
}

resource "aws_s3_bucket_notification" "output" {
  bucket = aws_s3_bucket.output.id

  topic {
    topic_arn = aws_sns_topic.s3_events.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_sns_topic_policy.s3_events]
}

resource "aws_s3_bucket_lifecycle_configuration" "output" {
  bucket = aws_s3_bucket.output.id

  rule {
    id     = "output_lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket" "working" {
  bucket = "${var.stack_name}-pattern2-working-${data.aws_caller_identity.current.account_id}"
  
  tags = merge(
    local.tags,
    {
      Name = "${var.stack_name}-pattern2-working"
      Type = "Working"
    }
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "working" {
  bucket = aws_s3_bucket.working.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.idp.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "working" {
  bucket = aws_s3_bucket.working.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "working" {
  bucket = aws_s3_bucket.working.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "working" {
  bucket = aws_s3_bucket.working.id

  target_bucket = aws_s3_bucket.working.id
  target_prefix = "access-logs/"
}

resource "aws_s3_bucket_notification" "working" {
  bucket = aws_s3_bucket.working.id

  topic {
    topic_arn = aws_sns_topic.s3_events.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_sns_topic_policy.s3_events]
}

resource "aws_s3_bucket_lifecycle_configuration" "working" {
  bucket = aws_s3_bucket.working.id

  rule {
    id     = "working_lifecycle"
    status = "Enabled"

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket" "configuration" {
  bucket = "${var.stack_name}-pattern2-config-${data.aws_caller_identity.current.account_id}"
  
  tags = merge(
    local.tags,
    {
      Name = "${var.stack_name}-pattern2-config"
      Type = "Configuration"
    }
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "configuration" {
  bucket = aws_s3_bucket.configuration.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.idp.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "configuration" {
  bucket = aws_s3_bucket.configuration.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "configuration" {
  bucket = aws_s3_bucket.configuration.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "configuration" {
  bucket = aws_s3_bucket.configuration.id

  target_bucket = aws_s3_bucket.configuration.id
  target_prefix = "access-logs/"
}

resource "aws_s3_bucket_notification" "configuration" {
  bucket = aws_s3_bucket.configuration.id

  topic {
    topic_arn = aws_sns_topic.s3_events.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

  depends_on = [aws_sns_topic_policy.s3_events]
}

resource "aws_s3_bucket_lifecycle_configuration" "configuration" {
  bucket = aws_s3_bucket.configuration.id

  rule {
    id     = "configuration_lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ----------------------------------------
# DynamoDB Tables
# ----------------------------------------
resource "aws_dynamodb_table" "tracking" {
  name           = "${var.stack_name}-pattern2-tracking"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "execution_id"
  
  attribute {
    name = "execution_id"
    type = "S"
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.idp.arn
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  tags = merge(
    local.tags,
    {
      Name = "${var.stack_name}-pattern2-tracking"
      Type = "Tracking"
    }
  )
}

resource "aws_dynamodb_table" "configuration" {
  name           = "${var.stack_name}-pattern2-configuration"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "pattern"
  
  attribute {
    name = "pattern"
    type = "S"
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.idp.arn
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  tags = merge(
    local.tags,
    {
      Name = "${var.stack_name}-pattern2-configuration"
      Type = "Configuration"
    }
  )
}

# ----------------------------------------
# Cross-Region Replication Resources
# ----------------------------------------
# Replica KMS Key in destination region
resource "aws_kms_key" "replica" {
  count                   = var.enable_cross_region_replication ? 1 : 0
  provider                = aws.replica
  description             = "KMS key for IDP Pattern 2 replica encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  tags = local.tags
}

resource "aws_kms_alias" "replica" {
  count         = var.enable_cross_region_replication ? 1 : 0
  provider      = aws.replica
  name          = "alias/${var.stack_name}-pattern2-replica"
  target_key_id = aws_kms_key.replica[0].key_id
}

# Replica buckets in destination region
resource "aws_s3_bucket" "input_replica" {
  count    = var.enable_cross_region_replication ? 1 : 0
  provider = aws.replica
  bucket   = "${var.stack_name}-pattern2-input-replica-${data.aws_caller_identity.current.account_id}"
  
  tags = merge(
    local.tags,
    {
      Name = "${var.stack_name}-pattern2-input-replica"
      Type = "InputReplica"
    }
  )
}

resource "aws_s3_bucket_versioning" "input_replica" {
  count    = var.enable_cross_region_replication ? 1 : 0
  provider = aws.replica
  bucket   = aws_s3_bucket.input_replica[0].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Replication IAM Role
resource "aws_iam_role" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0
  name  = "${var.stack_name}-pattern2-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "replication" {
  count = var.enable_cross_region_replication ? 1 : 0
  name  = "${var.stack_name}-pattern2-replication-policy"
  role  = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl"
        ]
        Resource = "${aws_s3_bucket.input.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.input.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete"
        ]
        Resource = "${aws_s3_bucket.input_replica[0].arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          aws_kms_key.idp.arn,
          aws_kms_key.replica[0].arn
        ]
      }
    ]
  })
}

# ----------------------------------------
# SNS Topic for S3 Event Notifications
# ----------------------------------------
resource "aws_sns_topic" "s3_events" {
  name              = "${var.stack_name}-pattern2-s3-events"
  kms_master_key_id = aws_kms_key.idp.id
  
  tags = merge(
    local.tags,
    {
      Name = "${var.stack_name}-pattern2-s3-events"
      Type = "S3Events"
    }
  )
}

resource "aws_sns_topic_policy" "s3_events" {
  arn = aws_sns_topic.s3_events.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Publish"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.s3_events.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# ----------------------------------------
# Pattern 2 Module
# ----------------------------------------
module "pattern_2" {
  source = "../../"
  
  stack_name                   = var.stack_name
  input_bucket                 = aws_s3_bucket.input.id
  configuration_bucket         = aws_s3_bucket.configuration.id
  output_bucket                = aws_s3_bucket.output.id
  working_bucket               = aws_s3_bucket.working.id
  tracking_table               = aws_dynamodb_table.tracking.name
  configuration_table          = aws_dynamodb_table.configuration.name
  customer_managed_key_arn     = aws_kms_key.idp.arn
  
  # S3 Bucket ARNs for UI integration
  input_bucket_arn             = aws_s3_bucket.input.arn
  output_bucket_arn            = aws_s3_bucket.output.arn
  working_bucket_arn           = aws_s3_bucket.working.arn
  tracking_table_arn           = aws_dynamodb_table.tracking.arn
  configuration_table_arn      = aws_dynamodb_table.configuration.arn
  
  # Optional features
  is_summarization_enabled     = var.enable_summarization
  is_assessment_enabled        = var.enable_assessment
  
  # Logging
  log_retention_days          = var.log_retention_days
  log_level                   = var.log_level
  
  # Environment
  environment                 = var.environment
  
  # UI Configuration
  app_name                    = "IDP Pattern 2 - ${var.environment}"
  admin_user_email           = var.admin_user_email
  admin_user_name            = var.admin_user_name
  admin_temp_password        = var.admin_temp_password
  
  # Update callback URLs with CloudFront domain (will be set after deployment)
  cognito_callback_urls      = var.enable_custom_domain && var.custom_domain != null ? [
    "https://${var.custom_domain}/",
    "https://${var.custom_domain}/auth/"
  ] : [
    "http://localhost:3000/",
    "https://localhost:3000/"
  ]
  
  cognito_logout_urls        = var.enable_custom_domain && var.custom_domain != null ? [
    "https://${var.custom_domain}/",
    "https://${var.custom_domain}/auth/"
  ] : [
    "http://localhost:3000/",
    "https://localhost:3000/"
  ]
  
  # Custom domain configuration
  custom_domain = var.enable_custom_domain && var.custom_domain != null && var.certificate_arn != null ? {
    domain_name      = var.custom_domain
    certificate_arn  = var.certificate_arn
    hosted_zone_id   = var.hosted_zone_id
  } : null
  
  tags = local.tags
}

# ----------------------------------------
# Local Variables
# ----------------------------------------
locals {
  tags = {
    Project     = "IDP"
    Pattern     = "2"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Example     = "Basic"
  }
}