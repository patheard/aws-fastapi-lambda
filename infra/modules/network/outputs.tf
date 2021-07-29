output "lambda_subnet_id" {
    description = "Lambda's subnet ID"
    value       = aws_subnet.api_subnet.id
}

output "lambda_security_group_id" {
    description = "Lambda's security group ID"
    value       = aws_security_group.lambda_security_group.id
}