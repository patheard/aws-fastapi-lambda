resource "aws_flow_log" "api_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.api_vpc.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs_group" {
  # checkov:skip=CKV_AWS_158:Default service key encryption is acceptable
  name              = "/aws/vpc-flow-logs/${var.project_name}-vpc"
  retention_in_days = 14

  tags = {
    Project = var.project_name
    Billing = var.project_team
  }
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name               = "VpcFlowLogsRole"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume_policy.json
}

resource "aws_iam_policy" "vpc_flow_logs_policy" {
  name        = "VpcFlowLogsCloudWatchLogging"
  description = "IAM policy for VPC flow logs"
  path        = "/"
  policy      = data.aws_iam_policy_document.vpc_flow_logs_cloudwatch_log_policy.json
}

resource "aws_iam_role_policy_attachment" "vpc_flow_logs_policy_attachment" {
  role       = aws_iam_role.vpc_flow_logs_role.name
  policy_arn = aws_iam_policy.vpc_flow_logs_policy.arn
}

data "aws_iam_policy_document" "vpc_flow_logs_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vpc_flow_logs_cloudwatch_log_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.vpc_flow_logs_group.arn,
      "${aws_cloudwatch_log_group.vpc_flow_logs_group.arn}:log-stream:*"
    ]
  }
}
