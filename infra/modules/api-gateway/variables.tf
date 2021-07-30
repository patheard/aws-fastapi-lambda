variable "lambda_subnet_ids" {
  description = "Lambda's subnet IDs"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "Lambda's security group ID"
  type        = string
}
