data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/scripts/lambda"
output_path = "${path.module}/scripts/lambda/lambda_function.zip"
}

resource "aws_lambda_function" "slack" {
filename                       = "${path.module}/scripts/lambda/lambda_function.zip"
function_name                  = "${var.env}-slack-lambda-function"
role                           =  aws_iam_role.slack.arn
handler                       =  "lambda_function.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.slack]
}

resource "aws_cloudwatch_event_rule" "slack" {
  name          = "${var.env}-slack-glue-alerts"
  description   = "Send AWS Glue Health events to Slack"
  event_pattern = <<-EOT
  {
  "detail": {
    "state": ["FAILED", "ERROR", "TIMEOUT", "STOPPED"]
  },
  "detail-type": ["Glue Job State Change"],
  "source": ["aws.glue"]
}
 EOT
}

resource "aws_cloudwatch_event_target" "slack" {
  rule      = aws_cloudwatch_event_rule.slack.name
  target_id = "Slack_Lambda_Function"
  arn       = aws_lambda_function.slack.arn
}

resource "aws_lambda_permission" "slack" {
  statement_id  = "AllowsCloudwwatchEventbridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.slack.arn
}