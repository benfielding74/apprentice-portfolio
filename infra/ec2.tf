# Create an EC2 instance
resource "aws_instance" "portfolio" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.portfolio[0].id
  vpc_security_group_ids = [
    aws_security_group.instance_security_group.id
  ]

  user_data = <<-EOF
                      #!/bin/bash
                      aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 617111187959.dkr.ecr.eu-west-2.amazonaws.com
                      docker pull 617111187959.dkr.ecr.eu-west-2.amazonaws.com/app-portfolio
                      docker run -p 80:80 617111187959.dkr.ecr.eu-west-2.amazonaws.com/app-portfolio
                      EOF
}

# Attach the EC2 instance to the target group
resource "aws_lb_target_group_attachment" "portfolio" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.portfolio.id
  port             = 80
}