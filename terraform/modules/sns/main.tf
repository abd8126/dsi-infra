resource "aws_sns_topic" "glue_sns" {
  name = "${terraform.workspace}-glue-status-check-sns"
  display_name = "${terraform.workspace}-glue-job-status-alert"
}

resource "aws_sns_topic_subscription" "glue_sns" {
  count      = length(var.endpoint)
  topic_arn = "${aws_sns_topic.glue_sns.arn}"
  protocol  = "email"
  endpoint  =  "${var.endpoint[count.index]}"
  endpoint_auto_confirms = "true"
}

resource "aws_cloudwatch_event_rule" "gluejob_status" {
  name        = "${terraform.workspace}-glue-job-status-check"

  event_pattern = <<EOF
{
  "detail-type": ["Glue Job State Change"],
  "source": ["aws.glue"],
  "detail": {
    "state": ["FAILED", "ERROR", "TIMEOUT", "STOPPED"]
  }
}
EOF
}
 
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.gluejob_status.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.glue_sns.arn
}