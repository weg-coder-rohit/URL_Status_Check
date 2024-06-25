# Create IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role-url-checker"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM role policies for lamda function

resource "aws_iam_policy_attachment" "lambda_sns_policy_attachment" {
  name       = "lambda-sns-policy"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_eventbridge_policy_attachment" {
  name       = "lambda-eventbridge-policy"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Creating Lambda function ZIP file using data source for lambda function to use
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/lambda_function.zip"
}

# Creating Lambda function
resource "aws_lambda_function" "url_checker_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = 60

  # Passign sns topic arn as enviornment variable for security purpose
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}

# Creating AWS eventbridge schedule rule to invoke the lambda function after every 1 hour
resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "InvokeUrlCheckerLambdaRule"
  description         = "Schedule to invoke URL checker Lambda function"
  schedule_expression = "rate(1 hour)"  

  event_pattern = <<PATTERN
{
  "source": ["aws.events"],
  "detail-type": ["Scheduled Event"],
  "resources": ["*"]
}
PATTERN
}

# creating eventbridge rule and target the lambda function 
resource "aws_cloudwatch_event_target" "invoke_lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "InvokeUrlCheckerLambdaTarget"
  arn       = aws_lambda_function.url_checker_lambda.arn
  // Passing url dynamically as part of the event detail we can change it manually in eventbridg rule
  input = jsonencode({
    key1 = "https://youtube.com"  // we can give this url dynamically
  })

    # lifecycle metadata ignore_changes = all is used to ignore the changes made to the resource after its creation 
    # I am ignoring it on purpose for manually triggering the lambda function for testing purpose as it was changing after every plan
    lifecycle {
    ignore_changes = all
  }
}



# Create SNS topic
resource "aws_sns_topic" "alerts" {
  name = "url-checker-alerts"
  display_name = "URL Checker Alerts"
}

# Subscribe email to SNS topic "We have to subscribe manually once"
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email_subscription
}