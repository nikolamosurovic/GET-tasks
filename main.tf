# Create VPC
resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.0.0.0/16" 
  enable_dns_support   = true          
  enable_dns_hostnames = true

  tags = {
    Name = "test-vpc"
  }
}

# Create public subnets in two availability zones
resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "test-subnet"
  }
}

resource "aws_subnet" "test_subnet_2" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1b"

  tags = {
    Name = "test-subnet-2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test-igw"
  }
}

# Create a route table
resource "aws_route_table" "test_route_table" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  tags = {
    Name = "test-route-table"
  }
}

# Route Table Association for the first subnet
resource "aws_route_table_association" "test_route_table_assoc" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.test_route_table.id
}

# Route Table Association for the second subnet
resource "aws_route_table_association" "test_route_table_assoc_2" {
  subnet_id      = aws_subnet.test_subnet_2.id
  route_table_id = aws_route_table.test_route_table.id
}

# Security groups for EC2 and RDS
resource "aws_security_group" "test_ec2_sg" {
  name        = "test-ec2-security-group"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-ec2-security-group"
  }
}

resource "aws_security_group" "test_rds_sg" {
  name        = "test-rds-security-group"
  description = "Allow EC2 instance to connect to RDS"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description     = "Allow PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.test_ec2_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-rds-security-group"
  }
}

# Create a key pair for SSH access
resource "aws_key_pair" "my_pub_key" {
  key_name   = "my-public-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# EC2 instance
resource "aws_instance" "test_ec2" {
  ami                    = "ami-071f0796b00a3a89d" # Amazon Linux 2 AMI for eu-central-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test_subnet.id
  vpc_security_group_ids = [aws_security_group.test_ec2_sg.id]
  key_name               = aws_key_pair.my_pub_key.key_name

  user_data = <<EOT
            #!/bin/bash
            sudo yum update -y
            sudo amazon-linux-extras enable postgresql14
            sudo yum install -y httpd postgresql
            sudo systemctl start httpd
            sudo systemctl enable httpd
  EOT

  tags = {
    Name        = "test-ec2-instance"
    Description = "Test instance"
    CostCenter  = "123456"
  }
}

