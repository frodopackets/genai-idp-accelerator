terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "bedrock-data-automation"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.bucket_name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  common_tags = {
    Purpose     = "BedrockDataAutomation"
    ManagedBy   = "Terraform"
    Project     = "IDP-Accelerator"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "bedrock_data_automation" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "bedrock_data_automation" {
  bucket = aws_s3_bucket.bedrock_data_automation.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_data_automation" {
  bucket = aws_s3_bucket.bedrock_data_automation.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bedrock_data_automation" {
  bucket = aws_s3_bucket.bedrock_data_automation.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bedrock_data_automation" {
  bucket = aws_s3_bucket.bedrock_data_automation.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.bedrock_data_automation.arn,
      "${aws_s3_bucket.bedrock_data_automation.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "AllowBedrockDataAutomationAccess"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.bedrock_data_automation.arn,
      "${aws_s3_bucket.bedrock_data_automation.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "bedrock_data_automation" {
  bucket = aws_s3_bucket.bedrock_data_automation.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.bedrock_data_automation.id
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.bedrock_data_automation.arn
}

output "bucket_region" {
  description = "Region of the created S3 bucket"
  value       = var.aws_region
}