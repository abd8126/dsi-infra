#IAM users
resource "aws_iam_user" "user1" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}TableauDsiDataConsumer"
}

/*

resource "aws_iam_user" "user2" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}ETLGlueServiceRunnerUser"
}

resource "aws_iam_user" "PreLandingUser" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}PreLandingUser"
}

resource "aws_iam_user" "AdminReadOnlyUser" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}AdminReadOnlyUser"
}

*/

# IAM groups

resource "aws_iam_group" "developers" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}ETLDevUserGroup"
  path = "/users/"
}

resource "aws_iam_group" "consumergrp" {
  count  = length(var.tenant)
  name = "${var.tenant[count.index]}DsiDataConsumerUserGroup"
  path = "/users/"
}

resource "aws_iam_user_group_membership" "Tableau" {
  count  = length(var.tenant)
  user = "${aws_iam_user.user1.*.name[count.index]}"

  groups =  [
  "${aws_iam_group.consumergrp.*.name[count.index]}"
  ]
}

resource "aws_iam_user_group_membership" "Tableau_1" {
  user = "${aws_iam_user.user1.*.name[0]}"

  groups =  [
  "${aws_iam_group.consumergrp.*.name[3]}"
  ]
}

resource "aws_iam_user_group_membership" "Tableau_" {
  user = "${aws_iam_user.user1.*.name[3]}"

  groups =  [
  "${aws_iam_group.consumergrp.*.name[0]}"
  ]
}
