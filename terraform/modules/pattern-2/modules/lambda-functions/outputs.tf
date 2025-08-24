# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "function_arns" {
  description = "Map of Lambda function ARNs"
  value = {
    ocr             = aws_lambda_function.ocr.arn
    classification  = aws_lambda_function.classification.arn
    extraction      = aws_lambda_function.extraction.arn
    assessment      = aws_lambda_function.assessment.arn
    summarization   = aws_lambda_function.summarization.arn
    process_results = aws_lambda_function.process_results.arn
  }
}

output "function_names" {
  description = "Map of Lambda function names"
  value = {
    ocr             = aws_lambda_function.ocr.function_name
    classification  = aws_lambda_function.classification.function_name
    extraction      = aws_lambda_function.extraction.function_name
    assessment      = aws_lambda_function.assessment.function_name
    summarization   = aws_lambda_function.summarization.function_name
    process_results = aws_lambda_function.process_results.function_name
  }
}

output "function_role_arns" {
  description = "Map of Lambda function IAM role ARNs"
  value = {
    ocr             = aws_iam_role.ocr.arn
    classification  = aws_iam_role.classification.arn
    extraction      = aws_iam_role.extraction.arn
    assessment      = aws_iam_role.assessment.arn
    summarization   = aws_iam_role.summarization.arn
    process_results = aws_iam_role.process_results.arn
  }
}

output "dlq_arn" {
  description = "Dead letter queue ARN"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_url" {
  description = "Dead letter queue URL"
  value       = aws_sqs_queue.dlq.url
}

output "layer_arn" {
  description = "Lambda layer ARN for common dependencies"
  value       = aws_lambda_layer_version.pattern2_dependencies.arn
}