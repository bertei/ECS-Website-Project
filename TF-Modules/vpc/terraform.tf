## VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "ecs-vpc"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

## Subnet
resource "aws_subnet" "main" {
  for_each = length(var.subnets) > 0 ? var.subnets : {}

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr  #.cidr -> way 1
  availability_zone = each.value["az"] #value["az"] -> way 2

  tags = {
    Name = "ecs-${each.key}"
  }  
}

## IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "ecs-igw"
  }
}

## Route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-routetable"
  }
}

resource "aws_route" "main" {
  route_table_id = aws_route_table.main.id

  gateway_id = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

#I have two subnets & 1 route table, therefore I need to associate two subnets to the single route table.
resource "aws_route_table_association" "main" {
  #For_each creates a map of objects from aws_subnet ("subnet-1" & "subnet-2") and iterates over them to create for each one a rt_association resource
  for_each = {for key, value in aws_subnet.main : key => value}
  route_table_id  = aws_route_table.main.id
  subnet_id       = each.value.id
}

## Security group
resource "aws_security_group" "main" {
  for_each = var.security_groups

  name        = each.key
  description = each.value.description
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.sg_ingress
    content {
      description      =  ingress.value.description
      from_port        =  ingress.value.from_port
      to_port          =  ingress.value.to_port
      protocol         =  ingress.value.protocol
      cidr_blocks      =  ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress
    content {
      description      =  egress.value.description
      from_port        =  egress.value.from_port
      to_port          =  egress.value.to_port
      protocol         =  egress.value.protocol
      cidr_blocks      =  egress.value.cidr_blocks
    }
  }

  #I leave this code block for testing purposes. I failed to create multiple sg's with dynamic rules.
  #dynamic "ingress" {
  #  for_each = {for key, value in var.security_groups : key => value.sg_ingress}
#
  #  content {
  #    description      =  ingress.value.description
  #    from_port        =  ingress.value.from_port
  #    to_port          =  ingress.value.to_port
  #    protocol         =  ingress.value.protocol
  #    cidr_blocks      =  ingress.value.cidr_blocks
  #  }
  #}

  tags = {
    Name = "${each.key}"
  }
}

## Loadbalancer
resource "aws_alb" "main" {
  name = "ecs-website-alb"
  load_balancer_type = "application"
  subnets = [ for subnet in aws_subnet.main : subnet.id ]
  security_groups = [ for sg in aws_security_group.main : sg.id ]

  tags = {
    Name = "ecs-website-alb"
  }
}

resource "aws_alb_target_group" "main" {
  name = "ecs-website-tg"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ecs-website-tg"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }

  tags = {
    Name = "ecs-website-http-listener"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "ecs-website-https-listener"
  }
}