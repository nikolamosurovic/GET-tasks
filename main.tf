# Create VPC
resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.0.0.0/16" 
  enable_dns_support   = true          
  enable_dns_hostnames = true

  tags = {
    Name = "test-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id # Associate with the VPC
  cidr_block              = "10.0.1.0/24"       # Subnet CIDR block
  map_public_ip_on_launch = true                # Automatically assign public IP
  availability_zone       = "eu-central-1a"     # Set availability zone

  tags = {
    Name = "test-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id # Attach to the VPC

  tags = {
    Name = "test-igw"
  }
}

# Create a route table
resource "aws_route_table" "test_route_table" {
  vpc_id = aws_vpc.test_vpc.id # Associate with the VPC

  # Add a route for all traffic to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  tags = {
    Name = "test-route-table"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "test_route_table_assoc" {
  subnet_id      = aws_subnet.test_subnet.id      # Associate with the subnet
  route_table_id = aws_route_table.test_route_table.id
}

# Create a security group for EC2 instance
resource "aws_security_group" "test_ec2_sg" {
  name        = "test-ec2-security-group"
  description = "Allow SSH and HTTP access"
  vpc_id      = aws_vpc.test_vpc.id # Associate with the VPC

  # Allow SSH access only from the specified public IP
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  # Allow HTTP access from anywhere
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
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

# Create a security group for RDS instance
resource "aws_security_group" "test_rds_sg" {
  name        = "test-rds-security-group"
  description = "Allow EC2 instance to connect to RDS"
  vpc_id      = aws_vpc.test_vpc.id

  # Allow PostgreSQL access from the EC2 security group
  ingress {
    description     = "Allow PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.test_ec2_sg.id] # Allow traffic from EC2 security group
  }

  # Allow all outbound traffic
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
resource "aws_key_pair" "test_key_pair" {
  key_name   = "test-existing-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Launch an EC2 instance
resource "aws_instance" "test_ec2" {
  ami           = "ami-0a49b025fffbbdac6" # Amazon Linux 2 AMI for eu-central-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.test_subnet.id
  key_name      = aws_key_pair.test_key_pair.key_name

  # Attach the vpc security group to the instance
  vpc_security_group_ids = [aws_security_group.test_ec2_sg.id]

  tags = {
    Name = "test-ec2-instance"
  }

  # Install Apache and PostgreSQL client using user_data
  user_data = <<EOT
            #!/bin/bash
            yum update -y
            yum install -y postgresql
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
  EOT
}

# Deploy a PostgreSQL RDS instance
resource "aws_db_instance" "test_rds" {
  allocated_storage       = 20
  max_allocated_storage   = 100
  engine                  = "postgres"
  engine_version          = "15.4"
  instance_class          = "db.t3.micro"
  username                = "dbadmin"

  # Use the password hash from variables.tf
  password = var.db_password_hash

  multi_az                = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.test_rds_sg.id]
  skip_final_snapshot     = true

  tags = {
    Name = "test-rds-instance"
  }
}
