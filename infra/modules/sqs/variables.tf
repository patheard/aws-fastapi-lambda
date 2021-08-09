variable "lambda_producer_function_name" {
  description = "Name of the Lambda function that produces messages for the SQS queue"
  type        = string
}

variable "max_receive_count" {
  description = "Max number of times a message can be processed without deletion before sent to the deadletter queue"
  type        = number
}
