# Define Security Group for Node.js Application
resource "aws_security_group" "nodeapp_sg" {
  vpc_id      = var.vpc_id
  name        = "node-app-sg"
  description = "Security group for Node.js application"

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  vpc_id      = var.vpc_id
  name        = "node-lb-sg"
  description = "Security group for Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

# Define IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the necessary policies to the IAM Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_cloudwatch_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
# Define ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = var.cluster_name
}

# Define Task Definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = var.family_name
  cpu                      = 1024  
  memory                   = 3072  
  container_definitions    = jsonencode([
    {
      name            = var.container_name
      image           = "${var.ecr_repository_url}:latest"
      cpu             = 1024  
      memory          = 3072  
      portMappings    = [{
        containerPort = 3000
        hostPort      = 3000  
        protocol      = "tcp"
      }]
    }
  ])
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

# Define ECS Service
resource "aws_ecs_service" "my_service" {
  name            = var.app_service
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1  
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [aws_security_group.nodeapp_sg.id]

    # Attach Elastic IP
    assign_public_ip = true  
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    container_name   = var.container_name
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.my_lb_listener]
}


# Define Load Balancer
resource "aws_lb" "my_lb" {
  name               = "my-lb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.lb_sg.id]

  enable_deletion_protection = false
}


resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

