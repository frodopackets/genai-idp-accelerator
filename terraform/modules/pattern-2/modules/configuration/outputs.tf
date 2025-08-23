# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "configuration_resource_id" {
  description = "ID of the configuration resource"
  value       = try(null_resource.pattern2_schema[0].id, null)
}

output "configuration_schema_hash" {
  description = "Hash of the configuration schema"
  value       = "pattern2-${md5(jsonencode(var.configuration_schema))}"
}