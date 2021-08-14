variable "lambda_subnet_ids" {
  description = "Lambda's subnet IDs"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "Lambda's security group ID"
  type        = string
}

variable "message_queue_arn" {
  description = "ARN of the SQS to send messages to"
  type        = string
}

variable "message_queue_name" {
  description = "Name of the SQS to send messages to"
  type        = string
}
