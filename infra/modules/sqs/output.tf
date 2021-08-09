output "message_queue_arn" {
  value = aws_sqs_queue.message_queue.arn
}

output "message_queue_url" {
  value = aws_sqs_queue.message_queue.url
}
