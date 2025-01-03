# RDS Subnet Group
resource "aws_db_subnet_group" "test_rds_subnet_group" {
  name       = "test-rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "test-rds-subnet-group"
    Env  = "test"
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "default" {
  name   = "default-db-parameter-group"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = {
    Name = "default-db-parameter-group"
    Env  = "test"
  }
}

# RDS Instance (Primary)
resource "aws_db_instance" "test_rds" {
  identifier              = "test-rds-primary"
  allocated_storage       = 50
  max_allocated_storage   = 100
  engine                  = "postgres"
  engine_version          = "14.14"
  instance_class          = "db.t3.micro"
  username                = "dbadmin"
  password                = var.db_password
  multi_az                = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.test_rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.test_rds_subnet_group.name
  backup_retention_period = 7
  parameter_group_name    = aws_db_parameter_group.default.name
  db_name                 = "testdb"
  skip_final_snapshot     = true

  tags = {
    Name = "test-rds-instance"
    Env  = "test"
  }
}

# RDS Read Replica
resource "aws_db_instance" "test_rds_replica" {
  replicate_source_db     = "test-rds-primary"
  instance_class          = "db.t3.micro"
  publicly_accessible     = false
  parameter_group_name    = aws_db_parameter_group.default.name
  apply_immediately       = true
  skip_final_snapshot     = true
  identifier              = "test-rds-replica"
  backup_retention_period = 7

  depends_on = [aws_db_instance.test_rds]

  vpc_security_group_ids = [
    aws_security_group.test_rds_sg.id
  ]

  tags = {
    Name    = "test-rds-replica"
    Replica = "true"
    Env     = "test"
  }
}
