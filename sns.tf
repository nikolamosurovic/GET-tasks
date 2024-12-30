# SNS topic
resource "aws_sns_topic" "daily_email_topic" {
  name = "daily-email-topic"
}

# Email subscription to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.daily_email_topic.arn
  protocol  = "email"
  endpoint  = "nikolamosurovic1@gmail.com"
}
