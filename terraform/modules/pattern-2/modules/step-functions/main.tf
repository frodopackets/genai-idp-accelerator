# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Step Functions Submodule
# ========================================
# This submodule manages the Step Functions state machine
# that orchestrates the Pattern 2 workflow.

# ----------------------------------------
# Data Sources
# ----------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ----------------------------------------
# Step Functions State Machine
# ----------------------------------------
resource "aws_sfn_state_machine" "pattern2_workflow" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.state_machine.arn
  
  definition = jsonencode({
    Comment = "Pattern 2 IDP Workflow - OCR, Classification, and Extraction"
    StartAt = "OCRStep"
    States = {
      OCRStep = {
        Type     = "Task"
        Resource = var.ocr_function_arn
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"]
            IntervalSeconds = 2
            MaxAttempts     = 6
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "FailState"
            ResultPath  = "$.error"
          }
        ]
        Next = "ClassificationStep"
      }
      
      ClassificationStep = {
        Type     = "Task"
        Resource = var.classification_function_arn
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"]
            IntervalSeconds = 2
            MaxAttempts     = 8
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "FailState"
            ResultPath  = "$.error"
          }
        ]
        Next = "ProcessPageGroups"
      }
      
      ProcessPageGroups = {
        Type = "Map"
        ItemsPath = "$.sections"
        MaxConcurrency = 10
        Iterator = {
          StartAt = "ExtractionStep"
          States = {
            ExtractionStep = {
              Type     = "Task"
              Resource = var.extraction_function_arn
              Retry = [
                {
                  ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"]
                  IntervalSeconds = 2
                  MaxAttempts     = 10
                  BackoffRate     = 2
                }
              ]
              Catch = [
                {
                  ErrorEquals = ["States.ALL"]
                  Next        = "ExtractionFailState"
                  ResultPath  = "$.error"
                }
              ]
              End = true
            }
            
            ExtractionFailState = {
              Type = "Fail"
              Cause = "Extraction step failed"
            }
          }
        }
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "FailState"
            ResultPath  = "$.error"
          }
        ]
        Next = "ProcessResultsStep"
      }
      
      ProcessResultsStep = {
        Type     = "Task"
        Resource = var.process_results_function_arn
        Retry = [
          {
            ErrorEquals     = ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"]
            IntervalSeconds = 2
            MaxAttempts     = 6
            BackoffRate     = 2
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next        = "FailState"
            ResultPath  = "$.error"
          }
        ]
        End = true
      }
      
      FailState = {
        Type  = "Fail"
        Cause = "Workflow execution failed"
      }
    }
  })
  
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.step_functions.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }
  
  tracing_configuration {
    enabled = true
  }
  
  tags = merge(
    var.tags,
    {
      Name = var.state_machine_name
      Type = "StateMachine"
    }
  )
}

# ----------------------------------------
# CloudWatch Log Group for Step Functions
# ----------------------------------------
resource "aws_cloudwatch_log_group" "step_functions" {
  name              = "/aws/stepfunctions/${var.state_machine_name}"
  retention_in_days = var.log_retention_days
  kms_key_id       = var.customer_managed_key_arn
  
  tags = merge(
    var.tags,
    {
      Name = "/aws/stepfunctions/${var.state_machine_name}"
      Type = "StepFunctionsLogs"
    }
  )
}