# Create security group for the load balancer
resource "aws_security_group" "instance_security_group" {
  name_prefix = "instance_security_group"
  vpc_id      = aws_vpc.portfolio.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.route53_ip_range]
  }
}

# Create an Application Load Balancer
resource "aws_lb" "portfolio" {
  name               = "portfolio-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.portfolio.id
  ]

  security_groups = [
    aws_security_group.instance_security_group.id
  ]
}

# Create a HTTPS listener on port 443
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.portfolio.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Create a target group for the EC2
resource "aws_lb_target_group" "target_group" {
  name_prefix = "folio"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.portfolio.id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
  }
}




