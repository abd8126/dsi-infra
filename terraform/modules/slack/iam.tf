
resource "template_file" "slack" {
    template = file("./policies/slack_lambda_trusted_relationship_role_policy.json.tpl")

  }

resource "aws_iam_role" "slack" {
  name               = "${var.env}-slack-lambda-execute"
  assume_role_policy = "${resource.template_file.slack.rendered}"
}


resource "aws_iam_role_policy_attachment" "slack" { 
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
  role       = "${aws_iam_role.slack.name}"
}