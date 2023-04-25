terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}

# Default vpc
data "aws_vpc" "default" {
  default = true
}

# Create subnet and security groups
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group" "lb" {
  name        = "lb-sg"
  description = "controls access to the Application Load Balancer (ALB)"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "allow inbound access from the ALB only"

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application load balancer
resource "aws_lb" "portfolio" {
  name               = "alb"
  subnets            = data.aws_subnet_ids.default.ids
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.portfolio.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.portfolio.arn
  }
}

resource "aws_lb_target_group" "portfolio" {
  name        = "portfolio-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}



# Create an ECS cluster
resource "aws_ecs_cluster" "portfolio" {
  name = "portfolio-site"
}

# Create an ecs task definition

resource "aws_ecs_task_definition" "portfolio" {
  family             = "portfolio-fargate"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode(
    [
      {
        "name" : "app-portfolio",
        "image" : "617111187959.dkr.ecr.eu-west-2.amazonaws.com/app-portfolio:latest",
        "portMappings" : [
          {
            "containerPort" : 80,
            "hostPort" : 80,
            "protocol" : "tcp"
          }
        ],
        "essential" : true,
        "entryPoint" : ["/usr/sbin/nginx"],
        "command" : ["-g 'daemon off;'"]
      }
    ]
  )
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = 256
  memory                   = 512
}

# Create an ECS fargate service
resource "aws_ecs_service" "portfolio" {
  name            = "portfolio"
  cluster         = aws_ecs_cluster.portfolio.id
  task_definition = aws_ecs_task_definition.portfolio.arn
  desired_count   = 1
  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnet_ids.default.ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.portfolio.arn
    container_name   = "app-portfolio"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.https_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

# IAM roles, policies and permissions 
# ECS needs perms to pull my image from ECR
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "portfolio-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Outputs

output "instance_dns_name" {
  value = aws_lb.portfolio.dns_name
}
