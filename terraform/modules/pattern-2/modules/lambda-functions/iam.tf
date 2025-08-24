# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# IAM Roles and Policies for Lambda Functions
# ========================================

locals {
  permissions_boundary = var.permissions_boundary_arn != "" ? var.permissions_boundary_arn : null
}

# ----------------------------------------
# OCR Lambda Function IAM Role
# ----------------------------------------
resource "aws_iam_role" "ocr" {
  name               = "${var.lambda_function_names["ocr"]}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  permissions_boundary = local.permissions_boundary
  
  tags = merge(
    var.tags,
    {
      Name = "${var.lambda_function_names["ocr"]}-role"
    }
  )
}

resource "aws_iam_role_policy" "ocr" {
  name   = "${var.lambda_function_names["ocr"]}-policy"
  role   = aws_iam_role.ocr.id
  policy = data.aws_iam_policy_document.ocr.json
}

resource "aws_iam_role_policy_attachment" "ocr_xray" {
  role       = aws_iam_role.ocr.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSXRayDaemonWriteAccess"
}

# VPC permissions for Lambda functions in VPC
resource "aws_iam_role_policy_attachment" "ocr_vpc" {
  count      = var.lambda_vpc_config != null ? 1 : 0
  role       = aws_iam_role.ocr.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ----------------------------------------
# Classification Lambda Function IAM Role
# ----------------------------------------
resource "aws_iam_role" "classification" {
  name               = "${var.lambda_function_names["classification"]}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  permissions_boundary = local.permissions_boundary
  
  tags = merge(
    var.tags,
    {
      Name = "${var.lambda_function_names["classification"]}-role"
    }
  )
}

resource "aws_iam_role_policy" "classification" {
  name   = "${var.lambda_function_names["classification"]}-policy"
  role   = aws_iam_role.classification.id
  policy = data.aws_iam_policy_document.classification.json
}

resource "aws_iam_role_policy_attachment" "classification_xray" {
  role       = aws_iam_role.classification.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSXRayDaemonWriteAccess"
}

# VPC permissions for Lambda functions in VPC
resource "aws_iam_role_policy_attachment" "classification_vpc" {
  count      = var.lambda_vpc_config != null ? 1 : 0
  role       = aws_iam_role.classification.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ----------------------------------------
# Extraction Lambda Function IAM Role
# ----------------------------------------
resource "aws_iam_role" "extraction" {
  name               = "${var.lambda_function_names["extraction"]}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  permissions_boundary = local.permissions_boundary
  
  tags = merge(
    var.tags,
    {
      Name = "${var.lambda_function_names["extraction"]}-role"
    }
  )
}

resource "aws_iam_role_policy" "extraction" {
  name   = "${var.lambda_function_names["extraction"]}-policy"
  role   = aws_iam_role.extraction.id
  policy = data.aws_iam_policy_document.extraction.json
}

resource "aws_iam_role_policy_attachment" "extraction_xray" {
  role       = aws_iam_role.extraction.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSXRayDaemonWriteAccess"
}

# VPC permissions for Lambda functions in VPC
resource "aws_iam_role_policy_attachment" "extraction_vpc" {
  count      = var.lambda_vpc_config != null ? 1 : 0
  role       = aws_iam_role.extraction.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ----------------------------------------
# Assessment Lambda Function IAM Role
# ----------------------------------------
resource "aws_iam_role" "assessment" {
  name               = "${var.lambda_function_names["assessment"]}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  permissions_boundary = local.permissions_boundary
  
  tags = merge(
    var.tags,
    {
      Name = "${var.lambda_function_names["assessment"]}-role"
    }
  )
}

resource "aws_iam_role_policy" "assessment" {
  name   = "${var.lambda_function_names["assessment"]}-policy"
  role   = aws_iam_role.assessment.id
  policy = data.aws_iam_policy_document.assessment.json
}

resource "aws_iam_role_policy_attachment" "assessment_xray" {
  role       = aws_iam_role.assessment.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSXRayDaemonWriteAccess"
}

# VPC permissions for Lambda functions in VPC
resource "aws_iam_role_policy_attachment" "assessment_vpc" {
  count      = var.lambda_vpc_config != null ? 1 : 0
  role       = aws_iam_role.assessment.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ----------------------------------------
# Summarization Lambda Function IAM Role
# ----------------------------------------
resource "aws_iam_role" "summarization" {
  name               = "${var.lambda_function_names["summarization"]}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  permissions_boundary = local.permissions_boundary
  
  tags = merge(
    var.tags,
    {
      Name = "${var.lambda_function_names["summarization"]}-role"
    }
  )
}

resource "aws_iam_role_policy" "summarization" {
  name   = "${var.lambda_function_names["summarization"]}-policy"
  role   = aws_iam_role.summarization.id
  policy = data.aws_iam_policy_document.summarization.json
}

resource "aws_iam_role_policy_attachment" "summarization_xray" {
  role       = aws_iam_role.summarization.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSXRayDaemonWriteAccess"
}

# VPC permissions for Lambda functions in VPC
resource "aws_iam_role_policy_attachment" "summarization_vpc" {
  count      = var.lambda_vpc_config != null ? 1 : 0
  role       = aws_iam_role.summarization.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ----------------------------------------
# Process Results Lambda Function IAM Role
# ----------------------------------------
resource "aws_iam_role" "process_results" {
  name               = "${var.lambda_function_names["process_results"]}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  permissions_boundary = local.permissions_boundary
  
  tags = merge(
    var.tags,
    {
      Name = "${var.lambda_function_names["process_results"]}-role"
    }
  )
}

resource "aws_iam_role_policy" "process_results" {
  name   = "${var.lambda_function_names["process_results"]}-policy"
  role   = aws_iam_role.process_results.id
  policy = data.aws_iam_policy_document.process_results.json
}

resource "aws_iam_role_policy_attachment" "process_results_xray" {
  role       = aws_iam_role.process_results.name
  policy_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSXRayDaemonWriteAccess"
}

# VPC permissions for Lambda functions in VPC
resource "aws_iam_role_policy_attachment" "process_results_vpc" {
  count      = var.lambda_vpc_config != null ? 1 : 0
  role       = aws_iam_role.process_results.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ========================================
# IAM Policy Documents
# ========================================

# Lambda Assume Role Policy
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

# OCR Lambda Policy
data "aws_iam_policy_document" "ocr" {
  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
  
  # S3 Access
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.input_bucket}/*",
      "arn:aws:s3:::${var.output_bucket}/*",
      "arn:aws:s3:::${var.working_bucket}/*",
      "arn:aws:s3:::${var.configuration_bucket}/*"
    ]
  }
  
  # Textract Access
  statement {
    effect = "Allow"
    actions = [
      "textract:DetectDocumentText",
      "textract:AnalyzeDocument"
    ]
    resources = ["*"]
  }
  
  # Bedrock Access (for OCR via Bedrock)
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = ["arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/*"]
  }
  
  # DynamoDB Access
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.tracking_table}",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.configuration_table}"
    ]
  }
  
  # KMS Access
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.customer_managed_key_arn]
  }
  
  # SQS DLQ Access
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.dlq.arn]
  }
}

# Classification Lambda Policy
data "aws_iam_policy_document" "classification" {
  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
  
  # S3 Access
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.output_bucket}/*",
      "arn:aws:s3:::${var.working_bucket}/*",
      "arn:aws:s3:::${var.configuration_bucket}/*"
    ]
  }
  
  # Bedrock Access
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = ["arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/*"]
  }
  
  # DynamoDB Access
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.tracking_table}",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.configuration_table}"
    ]
  }
  
  # KMS Access
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.customer_managed_key_arn]
  }
  
  # SQS DLQ Access
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.dlq.arn]
  }
}

# Extraction Lambda Policy
data "aws_iam_policy_document" "extraction" {
  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
  
  # S3 Access
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.output_bucket}/*",
      "arn:aws:s3:::${var.working_bucket}/*",
      "arn:aws:s3:::${var.configuration_bucket}/*"
    ]
  }
  
  # Bedrock Access
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = ["arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/*"]
  }
  
  # DynamoDB Access
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.tracking_table}",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.configuration_table}"
    ]
  }
  
  # KMS Access
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.customer_managed_key_arn]
  }
  
  # SQS DLQ Access
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.dlq.arn]
  }
}

# Assessment Lambda Policy
data "aws_iam_policy_document" "assessment" {
  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
  
  # S3 Access
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.output_bucket}/*",
      "arn:aws:s3:::${var.working_bucket}/*"
    ]
  }
  
  # Bedrock Access for assessment
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = ["arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/*"]
  }
  
  # DynamoDB Access
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.tracking_table}",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.configuration_table}"
    ]
  }
  
  # KMS Access
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.customer_managed_key_arn]
  }
  
  # SQS DLQ Access
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.dlq.arn]
  }
}

# Summarization Lambda Policy
data "aws_iam_policy_document" "summarization" {
  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
  
  # S3 Access
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.output_bucket}/*",
      "arn:aws:s3:::${var.working_bucket}/*"
    ]
  }
  
  # Bedrock Access for summarization
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = ["arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/*"]
  }
  
  # DynamoDB Access
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.tracking_table}",
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.configuration_table}"
    ]
  }
  
  # KMS Access
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.customer_managed_key_arn]
  }
  
  # SQS DLQ Access
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.dlq.arn]
  }
}

# Process Results Lambda Policy
data "aws_iam_policy_document" "process_results" {
  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
  
  # S3 Access
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.output_bucket}/*",
      "arn:aws:s3:::${var.working_bucket}/*"
    ]
  }
  
  # DynamoDB Access
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.tracking_table}"
    ]
  }
  
  # AppSync Access (if configured)
  dynamic "statement" {
    for_each = var.appsync_api_arn != "" ? [1] : []
    
    content {
      effect = "Allow"
      actions = [
        "appsync:GraphQL"
      ]
      resources = ["${var.appsync_api_arn}/*"]
    }
  }
  
  # KMS Access
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [var.customer_managed_key_arn]
  }
  
  # SQS DLQ Access
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.dlq.arn]
  }
}