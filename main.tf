provider "aws" {
	region = "${var.region}"
}


resource "aws_cloudwatch_event_rule" "config_events" {
  name        = "config-events"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.config"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_rule" "iam_events" {
  name        = "iam-events"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.iam"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_rule" "ec2_events" {
  name        = "ec2-events"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_rule" "console_events" {
  name        = "capture-aws-sign-in"
  description = "Capture each AWS Console Sign In"

  event_pattern = <<PATTERN
{
  "detail-type": [
    "AWS Console Sign In via CloudTrail"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "console_target" {
  rule      = "${aws_cloudwatch_event_rule.console_events.name}"
  arn       = "${aws_lambda_function.eventwatch_lambda.arn}"
}

resource "aws_cloudwatch_event_target" "ec2_target" {
  rule      = "${aws_cloudwatch_event_rule.ec2_events.name}"
  arn       = "${aws_lambda_function.eventwatch_lambda.arn}"
}

resource "aws_cloudwatch_event_target" "config_target" {
  rule      = "${aws_cloudwatch_event_rule.config_events.name}"
  arn       = "${aws_lambda_function.eventwatch_lambda.arn}"
}

resource "aws_cloudwatch_event_target" "iam_target" {
  rule      = "${aws_cloudwatch_event_rule.iam_events.name}"
  arn       = "${aws_lambda_function.eventwatch_lambda.arn}"
}

resource "aws_iam_role" "eventwatch_exec_role" {
	name = "eventwatch_exec_role"
	assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": "lambda.amazonaws.com"
			},
			"Effect": "Allow",
			"Sid": ""
		}
	]
}
EOF
}

data "aws_iam_policy_document" "eventwatch_s3_full_doc" {
    statement {
        actions = [
            "s3:*",
        ]
        resources = [
            "arn:aws:s3:::*",
        ]
    }
}

data "aws_iam_policy_document" "eventwatch_logs_full_doc" {
    statement {
        actions = [
            "logs:*",
        ]
        resources = [
	    "arn:aws:logs:*:*:*"
        ]
    }
}

resource "aws_iam_policy" "eventwatch_s3_full" {
    name = "eventwatch_s3_full"
    path = "/"
    policy = "${data.aws_iam_policy_document.eventwatch_s3_full_doc.json}"
}

resource "aws_iam_policy" "eventwatch_logs_full" {
    name = "eventwatch_logs_full"
    path = "/"
    policy = "${data.aws_iam_policy_document.eventwatch_logs_full_doc.json}"
}

# Now attach them
resource "aws_iam_role_policy_attachment" "eventwatch_s3_policy_attach" {
    role       = "${aws_iam_role.eventwatch_exec_role.name}"
    policy_arn = "${aws_iam_policy.eventwatch_s3_full.arn}"
}

resource "aws_iam_role_policy_attachment" "eventywatch_logs_policy_attach" {
    role       = "${aws_iam_role.eventwatch_exec_role.name}"
    policy_arn = "${aws_iam_policy.eventwatch_logs_full.arn}"
}

resource "aws_lambda_function" "eventwatch_lambda" {
	function_name = "eventwatch"
	handler = "lambda_function.lambda_handler"
	runtime = "python2.7"
	filename = "../eventwatch.zip"
	source_code_hash = "${base64sha256(file("eventwatch.zip"))}"
	role = "${aws_iam_role.eventwatch_exec_role.arn}"
	timeout = 15
}

resource "aws_lambda_permission" "allow_cloudwatch_iam_events" {
  statement_id   = "AllowExecutionFromCloudWatch1"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.eventwatch_lambda.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.iam_events.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_ec2_events" {
  statement_id   = "AllowExecutionFromCloudWatch2"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.eventwatch_lambda.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.ec2_events.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_config_events" {
  statement_id   = "AllowExecutionFromCloudWatch3"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.eventwatch_lambda.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.config_events.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_console_events" {
  statement_id   = "AllowExecutionFromCloudWatch4"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.eventwatch_lambda.function_name}"
  principal      = "events.amazonaws.com"
  source_arn     = "${aws_cloudwatch_event_rule.console_events.arn}"
}
