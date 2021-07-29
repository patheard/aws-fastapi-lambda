resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_function" "api_lambda" {
  filename      = "lambda.zip"
  function_name = "FastAPI"
  role          = aws_iam_role.api_lambda_role.arn
  handler       = "main.handler"
  runtime       = "python3.8"

  source_code_hash = filebase64sha256("lambda.zip")
}

resource "aws_iam_role" "api_lambda_role" {
  name               = "ApiLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
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
