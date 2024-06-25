provider "aws" {
  region = "ap-south-1"
}


  inline_policy {
    name = "lambda-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource  = "arn:aws:logs:*:*:*"
      },{
        Effect    = "Allow",
        Action    = [
          "sns:Publish"
        ],
        Resource  = aws_sns_topic.alerts.arn
      }]
    })
  }