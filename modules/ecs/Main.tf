################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "this" {
  name = "soat1-grp13-hackaton"
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${aws_ecs_cluster.this.name}"
  retention_in_days = 30
}

################################################################################
# Cluster Capacity Providers
################################################################################

resource "aws_ecs_cluster_capacity_providers" "this" {
  capacity_providers = ["FARGATE"]
  cluster_name       = aws_ecs_cluster.this.name
}

################################################################################
# Task Execution - IAM Role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
################################################################################

resource "aws_iam_role_policy_attachment" "default" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.task_exec.name
}

data "aws_iam_policy_document" "task_exec_assume" {
  statement {
    sid     = "ECSTaskExecutionAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_exec" {
  name               = "taskRole"
  assume_role_policy = data.aws_iam_policy_document.task_exec_assume.json


}

data "aws_iam_policy_document" "task_exec" {
  # Pulled from AmazonECSTaskExecutionRolePolicy
  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "GetSecrets"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }

  statement {
    sid       = "dynamoDb"
    actions   = ["dynamodb:*"]
    resources = [var.dynamo_arn]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "getSecretELog"
  policy = data.aws_iam_policy_document.task_exec.json
}

resource "aws_iam_role_policy_attachment" "task_exec_additional" {
  role       = aws_iam_role.task_exec.name
  policy_arn = aws_iam_policy.policy.arn
}

################################################################################
# Security Group
################################################################################

resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Security group to reference em RDS"
  vpc_id      = var.vpc_id
  tags = {
    Name = "ecs_sg"
  }
}

################################################################################
# Task Definition
################################################################################

resource "aws_ecs_task_definition" "relatorio" {
  container_definitions = jsonencode([{
    essential = true,
    image     = "christiandmelo/hackathon-soat1-grp13-relatorio:V1.0.19",
    name      = "relatorio-api",
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        appProtocol   = "http"
        protocol      = "tcp"
    }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-create-group  = "true",
        awslogs-group         = "/ecs/relatorio-api",
        awslogs-region        = "us-west-2",
        awslogs-stream-prefix = "ecs"
      },
      "secretOptions" : []
    },
  }])
  cpu                      = 256
  execution_role_arn       = aws_iam_role.task_exec.arn
  task_role_arn            = aws_iam_role.task_exec.arn
  family                   = "relatorio-api"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "ponto" {
  container_definitions = jsonencode([{
    essential = true,
    image     = "christiandmelo/hackathon-soat1-grp13-ponto:V1.0.18",
    name      = "ponto-api",
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        appProtocol   = "http"
        protocol      = "tcp"
    }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-create-group  = "true",
        awslogs-group         = "/ecs/ponto-api",
        awslogs-region        = "us-west-2",
        awslogs-stream-prefix = "ecs"
      },
      "secretOptions" : []
    },
  }])
  cpu                      = 256
  execution_role_arn       = aws_iam_role.task_exec.arn
  task_role_arn            = aws_iam_role.task_exec.arn
  family                   = "ponto-api"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "auth" {
  container_definitions = jsonencode([{
    essential = true,
    image     = "christiandmelo/hackathon-soat1-grp13-auth:V1.0.12",
    name      = "hackaton-auth-api",
    portMappings = [
      {
        containerPort = 8080
        hostPort      = 8080
        appProtocol   = "http"
        protocol      = "tcp"
    }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-create-group  = "true",
        awslogs-group         = "/ecs/hackaton-auth-api",
        awslogs-region        = "us-west-2",
        awslogs-stream-prefix = "ecs"
      },
      "secretOptions" : []
    },
  }])
  cpu                      = 256
  execution_role_arn       = aws_iam_role.task_exec.arn
  task_role_arn            = aws_iam_role.task_exec.arn
  family                   = "hackaton-auth-api"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_task_definition" "rabbitMQ" {
  container_definitions = jsonencode([{
    essential = true,
    image     = "rabbitmq:3-management",
    name      = "rabbitmq-api",
    portMappings = [
      {
        containerPort = 5672
        hostPort      = 5672
        appProtocol   = "http"
        protocol      = "tcp"
      },
      {
        containerPort = 15672
        hostPort      = 15672
        appProtocol   = "http"
        protocol      = "tcp"
      }
    ],
    //TODO passar isso para secrets do github actions
    environment = [
      { "name" : "RABBITMQ_DEFAULT_USER", "value" : var.rabbit_user },
      { "name" : "RABBITMQ_DEFAULT_PASS", "value" : var.rabbit_password },
      { "name" : "RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS", "value" : "-rabbitmq_management path_prefix \"/rabbitmanagement\"" },
      { "name" : "RABBITMQ_DEFAULT_VHOST", "value" : "/rabbit" }
    ]
  }])
  cpu                      = 256
  execution_role_arn       = aws_iam_role.task_exec.arn
  task_role_arn            = aws_iam_role.task_exec.arn
  family                   = "rabbitmq-api"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

################################################################################
# services
################################################################################

resource "aws_ecs_service" "ponto" {
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "ponto-service"
  task_definition = aws_ecs_task_definition.ponto.arn

  lifecycle {
    ignore_changes = [desired_count, task_definition] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  load_balancer {
    container_name   = "ponto-api"
    container_port   = 80
    target_group_arn = var.lb_target_group_ponto_arn
  }

  network_configuration {
    security_groups = [
      "${var.lb_engress_id}",
      "${var.lb_ingress_id}",
      aws_security_group.ecs_sg.id
    ]
    subnets          = var.privates_subnets_id
    assign_public_ip = false
  }
}

resource "aws_ecs_service" "rabbitmq" {
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "rabbitmq-service"
  task_definition = aws_ecs_task_definition.rabbitMQ.arn

  lifecycle {
    ignore_changes = [desired_count, task_definition] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  load_balancer {
    container_name   = "rabbitmq-api"
    container_port   = 5672
    target_group_arn = var.lb_target_group_rabbit_arn
  }
  load_balancer {
    container_name   = "rabbitmq-api"
    container_port   = 15672
    target_group_arn = var.lb_target_group_rabbit_management_arn
  }

  network_configuration {
    security_groups = [
      "${var.lb_engress_id}",
      "${var.lb_ingress_id}",
      aws_security_group.ecs_sg.id
    ]
    subnets          = var.privates_subnets_id
    assign_public_ip = false
  }
}

resource "aws_ecs_service" "relatorio" {
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "relatorio-service"
  task_definition = aws_ecs_task_definition.relatorio.arn

  lifecycle {
    ignore_changes = [desired_count, task_definition] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  load_balancer {
    container_name   = "relatorio-api"
    container_port   = 80
    target_group_arn = var.lb_target_group_relatorio_arn
  }

  network_configuration {
    security_groups = [
      "${var.lb_engress_id}",
      "${var.lb_ingress_id}",
      aws_security_group.ecs_sg.id
    ]
    subnets          = var.privates_subnets_id
    assign_public_ip = false
  }
}

resource "aws_ecs_service" "auth" {
  cluster         = aws_ecs_cluster.this.id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "auth-service"
  task_definition = aws_ecs_task_definition.auth.arn

  lifecycle {
    ignore_changes = [desired_count, task_definition] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  load_balancer {
    container_name   = "hackaton-auth-api"
    container_port   = 8080
    target_group_arn = var.lb_target_group_auth_arn
  }

  network_configuration {
    security_groups = [
      "${var.lb_engress_id}",
      "${var.lb_ingress_id}",
      aws_security_group.ecs_sg.id
    ]
    subnets          = var.privates_subnets_id
    assign_public_ip = false
  }
}




################################################################################
# Auto scaling
################################################################################

resource "aws_appautoscaling_target" "dev_to_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.ponto.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "dev_to_memory" {
  name               = "dev-to-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dev_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dev_to_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dev_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "dev_to_cpu" {
  name               = "dev-to-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dev_to_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dev_to_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dev_to_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80
  }
}
