output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.url_checker_lambda.arn
}


output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.alerts.arn
}