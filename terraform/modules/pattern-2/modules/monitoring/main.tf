# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Monitoring Submodule
# ========================================
# This submodule creates CloudWatch dashboards and alarms
# for monitoring Pattern 2 performance and health.

# ----------------------------------------
# Data Sources
# ----------------------------------------
data "aws_region" "current" {}

# ----------------------------------------
# CloudWatch Dashboard
# ----------------------------------------
resource "aws_cloudwatch_dashboard" "pattern2" {
  dashboard_name = "${var.resource_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/StepFunctions", "ExecutionsStarted", "StateMachineArn", var.state_machine_arn],
            [".", "ExecutionsSucceeded", ".", "."],
            [".", "ExecutionsFailed", ".", "."],
            [".", "ExecutionsTimedOut", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Step Functions Executions"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            for name, function_name in var.lambda_function_names : 
            ["AWS/Lambda", "Duration", "FunctionName", function_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda Function Durations"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            for name, function_name in var.lambda_function_names : 
            ["AWS/Lambda", "Errors", "FunctionName", function_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda Function Errors"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            for name, function_name in var.lambda_function_names : 
            ["AWS/Lambda", "Invocations", "FunctionName", function_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda Function Invocations"
          period  = 300
        }
      }
    ]
  })
  
  # CloudWatch dashboards don't support tags in Terraform AWS provider
}

# ----------------------------------------
# CloudWatch Alarms
# ----------------------------------------

# Step Functions Failed Executions Alarm
resource "aws_cloudwatch_metric_alarm" "step_functions_failures" {
  alarm_name          = "${var.resource_prefix}-step-functions-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name        = "ExecutionsFailed"
  namespace          = "AWS/StepFunctions"
  period             = 300
  statistic          = "Sum"
  threshold          = 0
  alarm_description  = "This metric monitors failed step function executions"
  treat_missing_data = "notBreaching"

  dimensions = {
    StateMachineArn = var.state_machine_arn
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-step-functions-failures"
    }
  )
}

# Lambda Function Error Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = var.lambda_function_names
  
  alarm_name          = "${var.resource_prefix}-${each.key}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = 300
  statistic          = "Sum"
  threshold          = 0
  alarm_description  = "This metric monitors errors for ${each.key} function"
  treat_missing_data = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-${each.key}-errors"
    }
  )
}

# Lambda Function Duration Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  for_each = var.lambda_function_names
  
  alarm_name          = "${var.resource_prefix}-${each.key}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name        = "Duration"
  namespace          = "AWS/Lambda"
  period             = 300
  statistic          = "Average"
  threshold          = var.execution_time_threshold_ms
  alarm_description  = "This metric monitors duration for ${each.key} function"
  treat_missing_data = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-${each.key}-duration"
    }
  )
}