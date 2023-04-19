# Create an EC2 instance
resource "aws_instance" "portfolio" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.portfolio.id
  vpc_security_group_ids = [
    aws_security_group.instance_security_group.id
  ]

  user_data = <<-EOF
                      #!/bin/bash
                      aws ecr get-login-password --region <ECR_REGION> | docker login --username AWS --password-stdin <ECR_REPO_URL>
                      docker pull <ECR_REPO_URL>/<DOCKER_IMAGE>
                      docker run -p 80:80 <ECR_REPO_URL>/<DOCKER_IMAGE>
                      EOF
}

# Attach the EC2 instance to the target group
resource "aws_lb_target_group_attachment" "portfolio" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.portfolio.id
  port             = 80
}