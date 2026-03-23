# 1. Application Load Balancer (Public-Facing)
resource "aws_lb" "app_alb" {
  name               = "cubic-defense-alb"
  internal           = false # Deployed as an internet-facing load balancer
  load_balancer_type = "application"

  # Attach public security group and deploy across highly available public subnets
  security_groups = [aws_security_group.public_sg.id]
  subnets         = module.vpc.public_subnets

  tags = {
    Name = "cubic-defense-alb"
  }
}

# 2. Target Group for Backend Application Servers
resource "aws_lb_target_group" "app_tg" {
  name     = "cubic-defense-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  # Health Check configuration to ensure traffic is only routed to healthy instances
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}

# 3. ALB Listener (Routing rules)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 4. Target Group Attachment
resource "aws_lb_target_group_attachment" "app_server_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id # Reference to the backend EC2 instance
  port             = 80
}