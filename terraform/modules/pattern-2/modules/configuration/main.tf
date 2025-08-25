# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# ========================================
# Configuration Submodule
# ========================================
# This submodule manages configuration schema updates
# and default configuration loading.

# ----------------------------------------
# Configuration Schema Management
# ----------------------------------------
# The configuration schema is managed through the main IDP stack
# This module provides the schema definition for reference
resource "null_resource" "pattern2_schema" {
  count = var.update_configuration_function_arn != "" ? 1 : 0
  
  triggers = {
    schema_hash = md5(jsonencode(var.configuration_schema))
  }
  
  # This can be used to trigger updates when schema changes
  lifecycle {
    create_before_destroy = true
  }
}