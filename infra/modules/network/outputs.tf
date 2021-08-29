output "lambda_subnet_ids" {
  description = "Lambda's subnet IDs"
  value       = module.high_availability_vpc.private_subnet_ids
}

output "lambda_security_group_id" {
  description = "Lambda's security group ID"
  value       = aws_security_group.lambda_security_group.id
}
