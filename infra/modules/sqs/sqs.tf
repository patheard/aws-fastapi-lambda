locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_sqs_queue" "message_queue" {
  name                      = "message-queue"
  max_message_size          = 1024
  message_retention_seconds = 86400 # 1 day
  kms_master_key_id         = "alias/aws/sqs"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.message_deadletter_queue.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name    = "${var.project_name}-message-queue"
    Project = var.project_name
    Billing = var.project_team
  }
}

# Only allow this account to send messages to the queue
resource "aws_sqs_queue_policy" "message_queue_policy" {
  queue_url = aws_sqs_queue.message_queue.id
  policy    = data.aws_iam_policy_document.message_queue_policy.json
}

data "aws_iam_policy_document" "message_queue_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:SendMessage*"
    ]
    resources = [
      aws_sqs_queue.message_queue.arn
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:lambda:${var.region}:${local.account_id}:function:${var.lambda_producer_function_name}*"
      ]
    }
  }
}

resource "aws_sqs_queue" "message_deadletter_queue" {
  name                      = "message-deadletter-queue"
  max_message_size          = 1024
  message_retention_seconds = 604800 # 1 week
  kms_master_key_id         = "alias/aws/sqs"

  tags = {
    Name    = "${var.project_name}-message-deadletter-queue"
    Project = var.project_name
    Billing = var.project_team
  }
}

# Only allow the message queue to send messages to the deadletter queue
resource "aws_sqs_queue_policy" "message_deadletter_queue_policy" {
  queue_url = aws_sqs_queue.message_deadletter_queue.id
  policy    = data.aws_iam_policy_document.message_deadletter_queue_policy.json
}

data "aws_iam_policy_document" "message_deadletter_queue_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:SendMessage*"
    ]
    resources = [
      aws_sqs_queue.message_deadletter_queue.arn
    ]
    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        aws_sqs_queue.message_queue.arn
      ]
    }
  }
}
