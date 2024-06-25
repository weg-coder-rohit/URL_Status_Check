variable "sns_email_subscription" {
  description = "Email address to subscribe for SNS alerts"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.8"
}