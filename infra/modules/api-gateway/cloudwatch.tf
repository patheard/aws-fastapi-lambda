resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.api_lambda.function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "LambdaCloudWatchLogging"
  description = "IAM policy for logging from a lambda"
  path        = "/"
  policy      = data.aws_iam_policy_document.lambda_cloudwatch_log_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
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
