# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# IAM Role and Policies for Step Functions
# ========================================

locals {
  permissions_boundary = var.permissions_boundary_arn != "" ? var.permissions_boundary_arn : null
}

# ----------------------------------------
# Step Functions IAM Role
# ----------------------------------------
resource "aws_iam_role" "state_machine" {
  name               = "${var.state_machine_name}-role"
  assume_role_policy = data.aws_iam_policy_document.step_functions_assume_role.json
  permissions_boundary = local.permissions_boundary
  
  tags = merge(
    var.tags,
    {
      Name = "${var.state_machine_name}-role"
    }
  )
}

resource "aws_iam_role_policy" "state_machine" {
  name   = "${var.state_machine_name}-policy"
  role   = aws_iam_role.state_machine.id
  policy = data.aws_iam_policy_document.state_machine.json
}

# ========================================
# IAM Policy Documents
# ========================================

# Step Functions Assume Role Policy
data "aws_iam_policy_document" "step_functions_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

# Step Functions Execution Policy
data "aws_iam_policy_document" "state_machine" {
  # Lambda Invocation
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      var.ocr_function_arn,
      var.classification_function_arn,
      var.extraction_function_arn,
      var.assessment_function_arn,
      var.summarization_function_arn,
      var.process_results_function_arn
    ]
  }
  
  # CloudWatch Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/stepfunctions/${var.state_machine_name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/stepfunctions/${var.state_machine_name}:*"
    ]
  }
  
  # CloudWatch Logs - Log Delivery (specific to Step Functions)
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.name]
    }
  }
  
  # CloudWatch Logs - Resource Policy Management
  statement {
    effect = "Allow"
    actions = [
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
  
  # X-Ray Tracing (region-scoped)
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.name]
    }
  }
}