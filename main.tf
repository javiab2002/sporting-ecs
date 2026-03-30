provider "aws" {
  region = "us-east-1"
}

# -------------------
# SECURITY GROUP ALB
# -------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP"
  vpc_id      = "vpc-018bf7f14af79bae3"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------
# SECURITY GROUP ECS
# -------------------
resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = "vpc-018bf7f14af79bae3"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------
# ALB
# -------------------
resource "aws_lb" "alb" {
  name               = "sporting-alb"
  load_balancer_type = "application"
  subnets = [
    "subnet-0d0b6f1044e948cb2",
    "subnet-0ea48be608e4e867f"
  ]
  security_groups = [aws_security_group.alb_sg.id]
}

# -------------------
# TARGET GROUP
# -------------------
resource "aws_lb_target_group" "tg" {
  name     = "sporting-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-018bf7f14af79bae3"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

# -------------------
# LISTENER
# -------------------
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# -------------------
# ECS CLUSTER
# -------------------
resource "aws_ecs_cluster" "cluster" {
  name = "SportingdeGijon"
}

# -------------------
# TASK DEFINITION
# -------------------
resource "aws_ecs_task_definition" "task" {
  family                   = "sporting-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  #execution_role_arn = "arn:aws:iam::339736979063:role/voclabs"

  container_definitions = jsonencode([
    {
      name      = "apache"
      #image     = "httpd:2.4"
      #image = "339736979063.dkr.ecr.us-east-1.amazonaws.com/sporting-gijon:latest"
      #image = "TU_USUARIO/sporting-gijon:latest"
      #image = "javiab2002/sporting-gijon:v1"
      image = "javiab2002/sporting-gijon:v3"	
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# -------------------
# ECS SERVICE
# -------------------
resource "aws_ecs_service" "service" {
  name            = "sporting-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets = [
      "subnet-0d0b6f1044e948cb2",
      "subnet-0ea48be608e4e867f"
    ]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
   }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "apache"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.listener]
}

