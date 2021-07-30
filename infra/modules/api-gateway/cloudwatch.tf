#
# Lambda CloudWatch logging
#
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  # checkov:skip=CKV_AWS_158:Default service key encryption is acceptable
  name              = "/aws/lambda/${aws_lambda_function.api_lambda.function_name}"
  retention_in_days = 14

  tags = {
    Project = var.project_name
    Billing = var.project_team
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "LambdaCloudWatchLogging"
  description = "IAM policy for logging from a lambda"
  path        = "/"
  policy      = data.aws_iam_policy_document.lambda_cloudwatch_log_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.api_lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "aws_iam_policy_document" "lambda_cloudwatch_log_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.lambda_log_group.arn,
      "${aws_cloudwatch_log_group.lambda_log_group.arn}:log-stream:*"
    ]
  }
}

#
# API Gateway CloudWatch logging
#
resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  # checkov:skip=CKV_AWS_158:Default service key encryption is acceptable
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.api_gateway.name}"
  retention_in_days = 14

  tags = {
    Project = var.project_name
    Billing = var.project_team
  }
}

# This account is used by all API Gateway resources in a region
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch_role.arn
}

resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name               = "ApiGatewayCloudwatchRole"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "api_gateway_logging_policy_attachment" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

data "aws_iam_policy_document" "api_gateway_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}
