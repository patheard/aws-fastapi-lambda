resource "aws_lambda_function" "api_lambda" {
  # checkov:skip=CKV_AWS_115:No function-level concurrent execution limit required
  # checkov:skip=CKV_AWS_116:No Dead Letter Queue required
  filename      = "lambda.zip"
  function_name = "FastAPI"
  role          = aws_iam_role.api_lambda_role.arn
  handler       = "main.handler"
  runtime       = "python3.8"

  source_code_hash = filebase64sha256("lambda.zip")

  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = {
    Name    = "${var.project_name}-function"
    Project = var.project_name
    Billing = var.project_team
  }
}

resource "aws_iam_role" "api_lambda_role" {
  name               = "ApiLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Allow the API gateway to invoke this lambda function
resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}
