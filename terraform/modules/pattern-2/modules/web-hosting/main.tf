# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Web Hosting Submodule
# ========================================
# This submodule manages CloudFront and S3 for Pattern 2 UI hosting:
# - S3 bucket for static web content
# - CloudFront distribution for global CDN
# - Origin Access Identity for security
# - Custom error pages and redirects

# ----------------------------------------
# Data Sources
# ----------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ----------------------------------------
# S3 Bucket for Web UI
# ----------------------------------------
resource "aws_s3_bucket" "web_ui" {
  bucket        = "${var.resource_prefix}-web-ui-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.force_destroy_bucket
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-web-ui"
      Type = "WebHosting"
    }
  )
}

# S3 Bucket Configuration
resource "aws_s3_bucket_versioning" "web_ui" {
  bucket = aws_s3_bucket.web_ui.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_ui" {
  bucket = aws_s3_bucket.web_ui.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.customer_managed_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.customer_managed_key_arn
    }
    bucket_key_enabled = var.customer_managed_key_arn != null ? true : null
  }
}

resource "aws_s3_bucket_public_access_block" "web_ui" {
  bucket = aws_s3_bucket.web_ui.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "web_ui" {
  bucket = aws_s3_bucket.web_ui.id
  
  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket Logging
resource "aws_s3_bucket_logging" "web_ui" {
  count = var.access_logging_bucket != null ? 1 : 0
  
  bucket        = aws_s3_bucket.web_ui.id
  target_bucket = var.access_logging_bucket
  target_prefix = "web-ui-access-logs/"
}

# ----------------------------------------
# CloudFront Origin Access Identity
# ----------------------------------------
resource "aws_cloudfront_origin_access_identity" "web_ui_oai" {
  comment = "OAI for ${var.resource_prefix} web UI"
}

# S3 Bucket Policy for CloudFront OAI
resource "aws_s3_bucket_policy" "web_ui_policy" {
  bucket = aws_s3_bucket.web_ui.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.web_ui_oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.web_ui.arn}/*"
      }
    ]
  })
}

# ----------------------------------------
# CloudFront Response Headers Policy
# ----------------------------------------
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name    = "${var.resource_prefix}-security-headers"
  comment = "Security headers for ${var.resource_prefix} web UI"
  
  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
    }
    
    content_type_options {
      override = true
    }
    
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
  
  custom_headers_config {
    items {
      header   = "X-Content-Security-Policy"
      value    = "default-src 'self' data: https://*.amazonaws.com https://*.amplifyapp.com; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://*.amazonaws.com wss://*.amazonaws.com"
      override = true
    }
  }
}

# ----------------------------------------
# CloudFront Distribution
# ----------------------------------------
resource "aws_cloudfront_distribution" "web_ui" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class
  comment             = "${var.resource_prefix} Web UI Distribution"
  
  # Origin configuration
  origin {
    domain_name = aws_s3_bucket.web_ui.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.web_ui.id}"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.web_ui_oai.cloudfront_access_identity_path
    }
  }
  
  # Default cache behavior
  default_cache_behavior {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = "S3-${aws_s3_bucket.web_ui.id}"
    compress                   = true
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }
  
  # Cache behavior for API calls (no caching)
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.web_ui.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    
    forwarded_values {
      query_string = true
      headers      = ["Authorization", "CloudFront-Forwarded-Proto"]
      cookies {
        forward = "all"
      }
    }
    
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }
  
  # Geographic restrictions (required)
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction != null ? var.geo_restriction.type : "none"
      locations        = var.geo_restriction != null ? var.geo_restriction.locations : []
    }
  }
  
  # SSL Certificate
  viewer_certificate {
    cloudfront_default_certificate = var.custom_domain == null
    acm_certificate_arn           = var.custom_domain != null ? var.custom_domain.certificate_arn : null
    ssl_support_method            = var.custom_domain != null ? "sni-only" : null
    minimum_protocol_version      = var.custom_domain != null ? "TLSv1.2_2021" : null
  }
  
  # Custom domain aliases
  aliases = var.custom_domain != null ? [var.custom_domain.domain_name] : []
  
  # Custom error responses for SPA
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
    error_caching_min_ttl = 86400
  }
  
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
    error_caching_min_ttl = 86400
  }
  
  # Logging configuration
  dynamic "logging_config" {
    for_each = var.access_logging_bucket != null ? [1] : []
    content {
      bucket          = var.access_logging_bucket
      prefix          = "cloudfront-access-logs/"
      include_cookies = false
    }
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-web-ui-distribution"
      Type = "CloudFrontDistribution"
    }
  )
}

# ----------------------------------------
# Route53 Record (if custom domain is provided)
# ----------------------------------------
resource "aws_route53_record" "web_ui_alias" {
  count = var.custom_domain != null ? 1 : 0
  
  zone_id = var.custom_domain.hosted_zone_id
  name    = var.custom_domain.domain_name
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.web_ui.domain_name
    zone_id                = aws_cloudfront_distribution.web_ui.hosted_zone_id
    evaluate_target_health = false
  }
}

# ----------------------------------------
# Default Web Content (placeholder files)
# ----------------------------------------
resource "aws_s3_object" "index_html" {
  count  = var.deploy_placeholder_content ? 1 : 0
  bucket = aws_s3_bucket.web_ui.id
  key    = "index.html"
  
  content = templatefile("${path.module}/web-content/index.html", {
    app_name         = var.app_name
    cognito_region   = data.aws_region.current.name
    user_pool_id     = var.cognito_user_pool_id
    user_pool_client_id = var.cognito_user_pool_client_id
    identity_pool_id = var.cognito_identity_pool_id
    appsync_graphql_endpoint = var.appsync_graphql_endpoint
  })
  
  content_type = "text/html"
  
  tags = merge(
    var.tags,
    {
      Name = "index.html"
      Type = "WebContent"
    }
  )
}

resource "aws_s3_object" "error_html" {
  count  = var.deploy_placeholder_content ? 1 : 0
  bucket = aws_s3_bucket.web_ui.id
  key    = "error.html"
  
  content      = file("${path.module}/web-content/error.html")
  content_type = "text/html"
  
  tags = merge(
    var.tags,
    {
      Name = "error.html"
      Type = "WebContent"
    }
  )
}