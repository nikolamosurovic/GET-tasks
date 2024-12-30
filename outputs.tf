output "ec2_public_ip" {
  value = aws_instance.test_ec2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.test_rds.address
}
