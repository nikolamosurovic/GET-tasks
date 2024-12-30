output "ec2_public_ip" {
  value = aws_instance.test_ec2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.test_rds.address
}

output "ec2_private_ip" {
  value = aws_instance.test_ec2.private_ip
  description = "Private IP address of the EC2 instance"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.daily_email_topic.arn
  description = "ARN of the SNS topic"
}

output "lambda_function_name" {
  value       = aws_lambda_function.send_daily_email.function_name
  description = "Name of the Lambda function"
}
