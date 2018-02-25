# terraform-eventwatch

TF to deploy http://github.com/mdfranz/eventwatch to a region

```
ubuntu@terraform:~/terraform-eventwatch$ tf apply --var 'region=ap-northeast-1'
aws_cloudwatch_event_rule.iam_events: Refreshing state... (ID: iam-events)
aws_cloudwatch_event_rule.config_events: Refreshing state... (ID: config-events)
aws_cloudwatch_event_rule.ec2_events: Refreshing state... (ID: ec2-events)
data.aws_iam_policy_document.eventwatch_logs_full_doc: Refreshing state...
aws_cloudwatch_event_rule.console_events: Refreshing state... (ID: capture-aws-sign-in)
aws_iam_role.eventwatch_exec_role: Refreshing state... (ID: eventwatch_exec_role)
aws_iam_policy.eventwatch_logs_full: Refreshing state... (ID: arn:aws:iam::XXXXXXXXX:policy/eventwatch_logs_full)
data.aws_iam_policy_document.eventwatch_s3_full_doc: Refreshing state...
[snip]
aws_cloudwatch_event_target.ec2_target: Creation complete after 1s (ID: ec2-events-terraform-20180225010117667700000004)
aws_lambda_permission.allow_cloudwatch_console_events: Creation complete after 3s (ID: AllowExecutionFromCloudWatch4)
aws_lambda_permission.allow_cloudwatch_config_events: Creation complete after 4s (ID: AllowExecutionFromCloudWatch3)
aws_lambda_permission.allow_cloudwatch_iam_events: Creation complete after 6s (ID: AllowExecutionFromCloudWatch1)

Apply complete! Resources: 18 added, 0 changed, 0 destroyed.```

