# Create a VPC
resource "aws_vpc" "portfolio" {
  cidr_block = "10.0.0.0/16"
}

# Create a subnet
resource "aws_subnet" "portfolio" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.portfolio.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = var.availability_zones[count.index]
}

# Create an Internet Gateway
resource "aws_internet_gateway" "portfolio" {
  vpc_id = aws_vpc.portfolio.id
}