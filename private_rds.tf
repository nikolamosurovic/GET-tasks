# RDS Subnet Group
resource "aws_db_subnet_group" "test_rds_subnet_group" {
  name       = "test-rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "test-rds-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "test_rds" {
  allocated_storage       = 20
  max_allocated_storage   = 100
  engine                  = "postgres"
  engine_version          = "14.14"
  instance_class          = "db.t3.micro"
  username                = "dbadmin"
  password                = var.db_password
  multi_az                = true
  publicly_accessible     = false # Ensures RDS does not get a public IP address
  vpc_security_group_ids  = [aws_security_group.test_rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.test_rds_subnet_group.name
  skip_final_snapshot     = true

  tags = {
    Name = "test-rds-instance"
  }
}
