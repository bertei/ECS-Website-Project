##ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  tags = {
    Name = "${var.ecs_cluster_name}"
  }
}

##ECS Task definition
resource "aws_ecs_task_definition" "main" {
  family = var.task_name

  container_definitions = jsonencode([
    {
      name      = "${var.container_name}"
      image     = "${var.image}:v1"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = "${aws_iam_role.main.arn}"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = {
    Name = "${var.task_name}"
  }
}

##ECS Fargate IAM Permissions
#ECS Task needs permissions over ECR & Cloudwatch.
resource "aws_iam_role" "main" {
  name = "ecs-fargate-task-executionrole"
  assume_role_policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "main" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [ "ecs-tasks.amazonaws.com" ]
    }
  }
}

#Attaches AWS Managed ECSTaskExecRolePolicy which grants the neccessary permissions on ECR & Log groups
resource "aws_iam_role_policy_attachment" "name" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##ECS Service
# main.tf
resource "aws_ecs_service" "main" {
  name            = var.service_name     # Name the service
  cluster         = aws_ecs_cluster.main.id   # Reference the created Cluster
  task_definition = aws_ecs_task_definition.main.arn # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1
  enable_execute_command = false
  #iam_role = aws_iam_role.main.arn

  load_balancer {
    target_group_arn = var.tg_arn # Reference the target group
    container_name   = "${var.container_name}"
    container_port   = 80 # Specify the container port
  }

  network_configuration {
    subnets          = var.subnet_id
    assign_public_ip = true     # Provide the containers with public IPs
    security_groups  = var.security_group_id # Set up the security group
  }

  tags = {
    Name = "${var.service_name}"
  }
}
