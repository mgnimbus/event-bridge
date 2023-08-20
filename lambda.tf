###############
# Lambda role
###############
resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_iam_${random_pet.randy.id}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


##################
# Lambda Function
##################

data "aws_secretsmanager_secret_version" "creds" {
  # Fill in the name you gave to your secret
  secret_id = "moogsoft"
}

locals {
  moogsoft_url     = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["moogsoft_url"]
  moogsoft_api_key = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["moogsoft_api_key"]
}

resource "aws_lambda_function" "lambda_processor" {
  function_name    = "event-processor-${random_pet.randy.id}"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  role             = aws_iam_role.lambda_iam.arn
  handler          = "event.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
  environment {
    variables = {
      moogsoft_url     = local.moogsoft_url
      moogsoft_api_key = local.moogsoft_api_key
    }
  }
}

provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "./scripts/event.py"
  output_path = "./scripts/event.zip"
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "./layers/requests.zip"
  layer_name = "requests_layer_name"

  compatible_runtimes = ["python3.11"]
}

resource "aws_lambda_permission" "event_bridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_processor.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_event_process.arn
}
