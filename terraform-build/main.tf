resource "aws_vpc" "terraform_build_vpc" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = false

  tags = {
    Name = "terraform-build-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.terraform_build_vpc.id
  cidr_block              = "10.30.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "terraform-public"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.terraform_build_vpc.id
  cidr_block              = "10.30.2.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "terraform-private1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.terraform_build_vpc.id
  cidr_block              = "10.30.3.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "terraform-private2"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.terraform_build_vpc.id

  tags = {
    Name = "terraform-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.terraform_build_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "terraform-public-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.terraform_build_vpc.id

  tags = {
    Name = "terraform-private-table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "terraform_sg" {
  name        = "terraform-sg"
  description = "test sg for terraform"
  vpc_id      = aws_vpc.terraform_build_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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