# EventBridge rule for daily schedule
resource "aws_cloudwatch_event_rule" "daily_schedule_rule" {
  name                = "daily-email-schedule"
  schedule_expression = "cron(0 1 * * ? *)" # every day at 1am
}

# Target for EventBridge rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_schedule_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.send_daily_email.arn
}

# Lambda permissions for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_daily_email.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_schedule_rule.arn
}
