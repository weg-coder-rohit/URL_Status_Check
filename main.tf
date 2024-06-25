module "url_checker" {
  source = "./module/url_checker"

  sns_email_subscription = "YourEmail@example.com"
  lambda_function_name   = "url-checker-lambda"
}