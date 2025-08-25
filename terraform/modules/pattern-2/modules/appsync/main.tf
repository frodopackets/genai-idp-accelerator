# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# AppSync GraphQL API Submodule
# ========================================
# This submodule manages the AppSync GraphQL API for Pattern 2 UI:
# - GraphQL API with comprehensive schema
# - Data sources (DynamoDB, Lambda, None)
# - Resolvers for all operations
# - Authentication and authorization

# ----------------------------------------
# Data Sources
# ----------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ----------------------------------------
# AppSync GraphQL API
# ----------------------------------------
resource "aws_appsync_graphql_api" "pattern2_api" {
  name                = "${var.resource_prefix}-api"
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  
  user_pool_config {
    aws_region         = data.aws_region.current.name
    user_pool_id       = var.cognito_user_pool_id
    default_action     = "ALLOW"
    app_id_client_regex = var.cognito_user_pool_client_id
  }
  
  additional_authentication_provider {
    authentication_type = "AWS_IAM"
  }
  
  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.appsync_logging.arn
    field_log_level          = var.log_level
  }
  
  schema = file("${path.module}/schema.graphql")
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-api"
      Type = "AppSyncAPI"
    }
  )
}

# ----------------------------------------
# AppSync Logging Role
# ----------------------------------------
resource "aws_iam_role" "appsync_logging" {
  name = "${var.resource_prefix}-appsync-logging-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-appsync-logging-role"
    }
  )
}

resource "aws_iam_role_policy" "appsync_logging" {
  name = "${var.resource_prefix}-appsync-logging-policy"
  role = aws_iam_role.appsync_logging.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

# ----------------------------------------
# DynamoDB Data Source
# ----------------------------------------
resource "aws_appsync_datasource" "tracking_table" {
  api_id           = aws_appsync_graphql_api.pattern2_api.id
  name             = "TrackingTable"
  type             = "AMAZON_DYNAMODB"
  service_role_arn = aws_iam_role.appsync_dynamodb.arn
  
  dynamodb_config {
    table_name = var.tracking_table_name
    region     = data.aws_region.current.name
  }
}

resource "aws_appsync_datasource" "configuration_table" {
  api_id           = aws_appsync_graphql_api.pattern2_api.id
  name             = "ConfigurationTable"
  type             = "AMAZON_DYNAMODB"
  service_role_arn = aws_iam_role.appsync_dynamodb.arn
  
  dynamodb_config {
    table_name = var.configuration_table_name
    region     = data.aws_region.current.name
  }
}

# ----------------------------------------
# DynamoDB Service Role
# ----------------------------------------
resource "aws_iam_role" "appsync_dynamodb" {
  name = "${var.resource_prefix}-appsync-dynamodb-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-appsync-dynamodb-role"
    }
  )
}

resource "aws_iam_role_policy" "appsync_dynamodb" {
  name = "${var.resource_prefix}-appsync-dynamodb-policy"
  role = aws_iam_role.appsync_dynamodb.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          var.tracking_table_arn,
          "${var.tracking_table_arn}/*",
          var.configuration_table_arn,
          "${var.configuration_table_arn}/*"
        ]
      }
    ]
  })
}

# ----------------------------------------
# Lambda Data Sources
# ----------------------------------------
resource "aws_appsync_datasource" "lambda_resolver" {
  for_each = var.resolver_functions
  
  api_id           = aws_appsync_graphql_api.pattern2_api.id
  name             = each.key
  type             = "AWS_LAMBDA"
  service_role_arn = aws_iam_role.appsync_lambda.arn
  
  lambda_config {
    function_arn = each.value
  }
}

# ----------------------------------------
# Lambda Service Role
# ----------------------------------------
resource "aws_iam_role" "appsync_lambda" {
  name = "${var.resource_prefix}-appsync-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-appsync-lambda-role"
    }
  )
}

resource "aws_iam_role_policy" "appsync_lambda" {
  count = length(var.resolver_functions) > 0 ? 1 : 0
  name = "${var.resource_prefix}-appsync-lambda-policy"
  role = aws_iam_role.appsync_lambda.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [for arn in var.resolver_functions : arn]
      }
    ]
  })
}

# ----------------------------------------
# None Data Source (for local resolvers)
# ----------------------------------------
resource "aws_appsync_datasource" "none" {
  api_id = aws_appsync_graphql_api.pattern2_api.id
  name   = "None"
  type   = "NONE"
}

# ----------------------------------------
# Resolvers
# ----------------------------------------

# Document Query Resolvers
resource "aws_appsync_resolver" "get_document" {
  api_id      = aws_appsync_graphql_api.pattern2_api.id
  field       = "getDocument"
  type        = "Query"
  data_source = aws_appsync_datasource.tracking_table.name
  
  request_template = file("${path.module}/resolvers/Query.getDocument.req.vtl")
  response_template = file("${path.module}/resolvers/Query.getDocument.res.vtl")
}

resource "aws_appsync_resolver" "list_documents" {
  api_id      = aws_appsync_graphql_api.pattern2_api.id
  field       = "listDocuments"
  type        = "Query"
  data_source = aws_appsync_datasource.tracking_table.name
  
  request_template = file("${path.module}/resolvers/Query.listDocuments.req.vtl")
  response_template = file("${path.module}/resolvers/Query.listDocuments.res.vtl")
}

# Document Mutation Resolvers
resource "aws_appsync_resolver" "create_document" {
  api_id      = aws_appsync_graphql_api.pattern2_api.id
  field       = "createDocument"
  type        = "Mutation"
  data_source = aws_appsync_datasource.tracking_table.name
  
  request_template = file("${path.module}/resolvers/Mutation.createDocument.req.vtl")
  response_template = file("${path.module}/resolvers/Mutation.createDocument.res.vtl")
}

resource "aws_appsync_resolver" "update_document" {
  api_id      = aws_appsync_graphql_api.pattern2_api.id
  field       = "updateDocument"
  type        = "Mutation"
  data_source = aws_appsync_datasource.tracking_table.name
  
  request_template = file("${path.module}/resolvers/Mutation.updateDocument.req.vtl")
  response_template = file("${path.module}/resolvers/Mutation.updateDocument.res.vtl")
}

# Lambda-backed resolvers
resource "aws_appsync_resolver" "lambda_resolvers" {
  for_each = var.lambda_resolvers
  
  api_id      = aws_appsync_graphql_api.pattern2_api.id
  field       = each.value.field
  type        = each.value.type
  data_source = aws_appsync_datasource.lambda_resolver[each.key].name
  
  request_template  = "$util.toJson($context)"
  response_template = "$util.toJson($context.result)"
}

# ----------------------------------------
# API Key (for development/testing)
# ----------------------------------------
resource "aws_appsync_api_key" "pattern2_api_key" {
  count = var.enable_api_key ? 1 : 0
  
  api_id      = aws_appsync_graphql_api.pattern2_api.id
  description = "API Key for Pattern 2 development"
  expires     = timeadd(timestamp(), "8760h") # 1 year
}