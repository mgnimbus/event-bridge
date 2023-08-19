###############
# Lambda role
###############
resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_iam"
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

provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "./scripts/event.py"
  output_path = "./scripts/event.zip"
}

##################
# Lambda Function
##################
resource "aws_lambda_function" "lambda_processor" {
  function_name    = "event-processor"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  role             = aws_iam_role.lambda_iam.arn
  handler          = "event.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
}


resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "./layers/requests.zip"
  layer_name = "requests_layer_name"

  compatible_runtimes = ["python3.11"]
}
