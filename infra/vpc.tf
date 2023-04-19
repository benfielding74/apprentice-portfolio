# Create a VPC
resource "aws_vpc" "portfolio" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet
resource "aws_subnet" "portfolio" {
  vpc_id     = aws_vpc.portfolio.id
  cidr_block = "10.0.1.0/24"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "portfolio" {
  vpc_id = aws_vpc.portfolio.id
}

# Attach the Internet Gateway to the VPC
resource "aws_internet_gateway_attachment" "portfolio" {
  internet_gateway_id = aws_internet_gateway.portfolio.id
  vpc_id              = aws_vpc.portfolio.id
}