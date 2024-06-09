provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role_new"  // Change the name here if needed

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = "ecs_task_execution_role_new"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = var.app_name
    image     = var.docker_image
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

resource "aws_ecs_service" "main" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0400c070122d51949", "subnet-0bcf8e690eccf2481"]
    security_groups = ["sg-0be051523e2124730"]
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:637423471839:targetgroup/hello-world-tg/ab574d7313db4ce4"
    container_name   = "hello-world-app"
    container_port   = 3000
  }
}

resource "aws_lb" "main" {
  name               = "hello-world-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0be051523e2124730"]
  subnets            = ["subnet-0400c070122d51949", "subnet-0bcf8e690eccf2481"]
}

resource "aws_lb_target_group" "main" {
  name     = "${var.app_name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "vpc-0d23f497331820272"  // Use your actual VPC ID
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
