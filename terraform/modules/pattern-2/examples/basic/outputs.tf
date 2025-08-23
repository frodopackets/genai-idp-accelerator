# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = module.pattern_2.state_machine_arn
}

output "state_machine_url" {
  description = "Console URL for the Step Functions state machine"
  value       = module.pattern_2.state_machine_url
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.pattern_2.dashboard_url
}

output "input_bucket" {
  description = "Input S3 bucket name"
  value       = aws_s3_bucket.input.id
}

output "output_bucket" {
  description = "Output S3 bucket name"
  value       = aws_s3_bucket.output.id
}

output "kms_key_arn" {
  description = "KMS key ARN used for encryption"
  value       = aws_kms_key.idp.arn
}