# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.pattern2_workflow.arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.pattern2_workflow.name
}

output "state_machine_url" {
  description = "Console URL for the Step Functions state machine"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/states/home?region=${data.aws_region.current.name}#/statemachines/view/${aws_sfn_state_machine.pattern2_workflow.arn}"
}

output "state_machine_role_arn" {
  description = "ARN of the Step Functions IAM role"
  value       = aws_iam_role.state_machine.arn
}

output "log_group_name" {
  description = "CloudWatch log group name for Step Functions"
  value       = aws_cloudwatch_log_group.step_functions.name
}