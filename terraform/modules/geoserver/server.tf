resource "aws_ecs_cluster" "geoserver" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "geoserver" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "geoserver"
      image     = "kartoza/geoserver:2.19.2"
      essential = true
      environment = [
        {
          name  = "GEOSERVER_DATA_DIR"
          value = "/mount/efs"
        },
        {
          name  = "GEOSERVER_ADMIN_USER"
          value = "admin"
        },
        {
          name  = "GEOSERVER_ADMIN_PASSWORD"
          value = "changethis"
        },
      ]
      mountPoints = [
        {
          sourceVolume  = "efs"
          containerPath = "/mount/efs"
          readOnly      = false
        }
      ]
      portMappings = [
        {
          containerPort = 8080
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${var.name}-geoserver-container"
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "geoserver"
          awslogs-create-group  = "true"

        }
      }
    }
  ])

  volume {
    name = "efs"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.efs.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.access_point.id
      }
    }
  }
}

resource "aws_security_group" "geoserver" {
  name        = var.name
  description = "Geoserver ECS SG"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "geoserver_efs_ingress" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.geoserver.id
}

resource "aws_security_group_rule" "geoserver_lb_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.geoserver.id
}

resource "aws_security_group_rule" "geoserver_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.geoserver.id
}

resource "aws_security_group" "lb" {
  name        = "${var.name}-lb"
  description = "Geoserver LB SG"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "lb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "geoserver_lb_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_lb" "geoserver" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "geoserver" {
  name        = var.name
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "http_to_https" {
  load_balancer_arn = aws_lb.geoserver.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    # Uncomment the 2 lines below for initial setup - Documented in README
    # type             = "forward"
    # target_group_arn = aws_lb_target_group.geoserver.arn

    # Comment out the type and redirect block below for initial setup
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.geoserver.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

  default_action {
    type = "redirect"
    redirect {
      path        = "/geoserver"
      port        = "#{port}"
      protocol    = "#{protocol}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "geoserver_path" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.geoserver.arn
  }

  condition {
    path_pattern {
      values = ["/geoserver*"]
    }
  }
}

resource "aws_ecs_service" "geoserver" {
  name                               = var.name
  cluster                            = aws_ecs_cluster.geoserver.id
  task_definition                    = aws_ecs_task_definition.geoserver.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  enable_execute_command             = true

  load_balancer {
    target_group_arn = aws_lb_target_group.geoserver.arn
    container_name   = "geoserver"
    container_port   = 8080
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.geoserver.id]
    assign_public_ip = false
  }
}
