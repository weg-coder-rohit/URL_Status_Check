module "url_checker" {
  source = "./module/url_checker"

  sns_email_subscription = "rohit.singh042499@gmail.com"
  lambda_function_name   = "url-checker-lambda"
}