# Lambda function for sending daily email
resource "aws_lambda_function" "send_daily_email" {
  function_name    = "send-daily-email"
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_exec_role.arn
  filename         = "lambda_function.zip"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.daily_email_topic.arn
    }
  }
}
