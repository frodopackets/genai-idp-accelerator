# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.pattern2.dashboard_name
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.pattern2.dashboard_name}"
}

output "alarm_arns" {
  description = "Map of CloudWatch alarm ARNs"
  value = merge(
    {
      step_functions_failures = aws_cloudwatch_metric_alarm.step_functions_failures.arn
    },
    {
      for k, v in aws_cloudwatch_metric_alarm.lambda_errors : 
      "${k}_errors" => v.arn
    },
    {
      for k, v in aws_cloudwatch_metric_alarm.lambda_duration : 
      "${k}_duration" => v.arn
    }
  )
}