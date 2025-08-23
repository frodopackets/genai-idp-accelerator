# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Lambda Functions Submodule
# ========================================
# This submodule manages all Lambda functions for Pattern 2:
# - OCR Function
# - Classification Function
# - Extraction Function
# - Process Results Function

# ----------------------------------------
# Data Sources
# ----------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ----------------------------------------
# Lambda Layer for Common Dependencies
# ----------------------------------------
resource "aws_lambda_layer_version" "pattern2_dependencies" {
  filename            = "${path.module}/layers/dependencies.zip"
  layer_name          = "${var.resource_prefix}-dependencies"
  compatible_runtimes = [var.lambda_runtime]
  description         = "Common dependencies for Pattern 2 Lambda functions"
  
  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------
# OCR Lambda Function
# ----------------------------------------
resource "aws_lambda_function" "ocr" {
  filename         = "${path.module}/functions/ocr/deployment.zip"
  function_name    = var.lambda_function_names["ocr"]
  role            = aws_iam_role.ocr.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  code_signing_config_arn = var.code_signing_config_arn != "" ? var.code_signing_config_arn : null
  
  layers = [aws_lambda_layer_version.pattern2_dependencies.arn]
  
  environment {
    variables = merge(
      var.common_env_vars,
      var.bedrock_env_vars,
      {
        FUNCTION_TYPE = "OCR"
      }
    )
  }
  
  kms_key_arn = var.customer_managed_key_arn
  
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
  
  # VPC Configuration (optional but recommended for security)
  dynamic "vpc_config" {
    for_each = var.lambda_vpc_config != null ? [var.lambda_vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tracing_config {
    mode = "Active"
  }
  
  tags = merge(
    var.tags,
    {
      Name         = var.lambda_function_names["ocr"]
      FunctionType = "OCR"
    }
  )
}

# ----------------------------------------
# Classification Lambda Function
# ----------------------------------------
resource "aws_lambda_function" "classification" {
  filename         = "${path.module}/functions/classification/deployment.zip"
  function_name    = var.lambda_function_names["classification"]
  role            = aws_iam_role.classification.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  code_signing_config_arn = var.code_signing_config_arn != "" ? var.code_signing_config_arn : null
  
  layers = [aws_lambda_layer_version.pattern2_dependencies.arn]
  
  environment {
    variables = merge(
      var.common_env_vars,
      var.bedrock_env_vars,
      {
        FUNCTION_TYPE = "CLASSIFICATION"
      }
    )
  }
  
  kms_key_arn = var.customer_managed_key_arn
  
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
  
  # VPC Configuration (optional but recommended for security)
  dynamic "vpc_config" {
    for_each = var.lambda_vpc_config != null ? [var.lambda_vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tracing_config {
    mode = "Active"
  }
  
  tags = merge(
    var.tags,
    {
      Name         = var.lambda_function_names["classification"]
      FunctionType = "Classification"
    }
  )
}

# ----------------------------------------
# Extraction Lambda Function
# ----------------------------------------
resource "aws_lambda_function" "extraction" {
  filename         = "${path.module}/functions/extraction/deployment.zip"
  function_name    = var.lambda_function_names["extraction"]
  role            = aws_iam_role.extraction.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  code_signing_config_arn = var.code_signing_config_arn != "" ? var.code_signing_config_arn : null
  
  layers = [aws_lambda_layer_version.pattern2_dependencies.arn]
  
  environment {
    variables = merge(
      var.common_env_vars,
      var.bedrock_env_vars,
      {
        FUNCTION_TYPE = "EXTRACTION"
      }
    )
  }
  
  kms_key_arn = var.customer_managed_key_arn
  
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
  
  # VPC Configuration (optional but recommended for security)
  dynamic "vpc_config" {
    for_each = var.lambda_vpc_config != null ? [var.lambda_vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tracing_config {
    mode = "Active"
  }
  
  tags = merge(
    var.tags,
    {
      Name         = var.lambda_function_names["extraction"]
      FunctionType = "Extraction"
    }
  )
}

# ----------------------------------------
# Process Results Lambda Function
# ----------------------------------------
resource "aws_lambda_function" "process_results" {
  filename         = "${path.module}/functions/process_results/deployment.zip"
  function_name    = var.lambda_function_names["process_results"]
  role            = aws_iam_role.process_results.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = var.lambda_runtime
  timeout         = 60
  memory_size     = 1024
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  code_signing_config_arn = var.code_signing_config_arn != "" ? var.code_signing_config_arn : null
  
  layers = [aws_lambda_layer_version.pattern2_dependencies.arn]
  
  environment {
    variables = merge(
      var.common_env_vars,
      {
        FUNCTION_TYPE = "PROCESS_RESULTS"
      }
    )
  }
  
  kms_key_arn = var.customer_managed_key_arn
  
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq.arn
  }
  
  # VPC Configuration (optional but recommended for security)
  dynamic "vpc_config" {
    for_each = var.lambda_vpc_config != null ? [var.lambda_vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tracing_config {
    mode = "Active"
  }
  
  tags = merge(
    var.tags,
    {
      Name         = var.lambda_function_names["process_results"]
      FunctionType = "ProcessResults"
    }
  )
}

# ----------------------------------------
# Dead Letter Queue for Lambda Functions
# ----------------------------------------
resource "aws_sqs_queue" "dlq" {
  name                       = "${var.resource_prefix}-lambda-dlq"
  message_retention_seconds  = 1209600  # 14 days
  visibility_timeout_seconds = 300
  
  kms_master_key_id = var.customer_managed_key_arn
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-lambda-dlq"
      Type = "DeadLetterQueue"
    }
  )
}

# ----------------------------------------
# CloudWatch Alarms for DLQ
# ----------------------------------------
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.resource_prefix}-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name        = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = 300
  statistic          = "Sum"
  threshold          = 0
  alarm_description  = "Alert when messages are in the DLQ"
  treat_missing_data = "notBreaching"
  
  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-dlq-alarm"
    }
  )
}