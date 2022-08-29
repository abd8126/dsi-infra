resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "create_log_group" {
  statement {
    actions = [
      "logs:CreateLogGroup"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "create_log_group" {
  name   = "${var.name}-create-log-group"
  path   = "/"
  policy = data.aws_iam_policy_document.create_log_group.json
}

resource "aws_iam_role_policy_attachment" "create_log_group" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.create_log_group.arn
}


resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

data "aws_iam_policy_document" "ecs_execute_command" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ecs_execute_command" {
  name   = "${var.name}-ecs-execute-command"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_execute_command.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_execute_command.arn
}
