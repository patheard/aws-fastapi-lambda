module "high_availability_vpc" {
  source = "github.com/cds-snc/terraform-modules?ref=8ad024269e0bd9096610baf34760d40eefc59de7//vpc"
  name   = "high_availability"

  high_availability = true
  enable_flow_log   = true
  allow_https_out   = true
  block_ssh         = true
  block_rdp         = true

  billing_tag_key   = "Business Unit"
  billing_tag_value = "Operations"
}


#
# Security groups
#

resource "aws_security_group" "vpc_endpoints" {
  name        = "VpcEndpoints"
  description = "VPC Endpoint security group"
  vpc_id      = module.high_availability_vpc.vpc_id
}

resource "aws_security_group" "lambda_security_group" {
  # checkov:skip=CKV2_AWS_5:False positive - SG is attached to Lambda in ./infra/modules/api-gateway/lambda.tf
  name        = "Lambda"
  description = "Allow TLS outbound traffic to CloudWatch from the Lambda"
  vpc_id      = module.high_availability_vpc.vpc_id
}

resource "aws_security_group_rule" "vpc_endpoints_from_lambda" {
  description              = "Security group rule for ingress to VPC endpoints"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpc_endpoints.id
  source_security_group_id = aws_security_group.lambda_security_group.id
}

resource "aws_security_group_rule" "lambda_to_vpc_endpoints" {
  description              = "Security group rule for egress to VPC endpoints"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_security_group.id
  source_security_group_id = aws_security_group.vpc_endpoints.id
}

resource "aws_security_group_rule" "lambda_egress" {
  description       = "Security group rule for egress to internet"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda_security_group.id
}

#
# PrivateLink endpoints to CloudWatch logs/monitoring
#

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.high_availability_vpc.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${var.region}.logs"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpc_endpoints.id,
  ]
  subnet_ids = module.high_availability_vpc.private_subnet_ids
}

resource "aws_vpc_endpoint" "monitoring" {
  vpc_id              = module.high_availability_vpc.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${var.region}.monitoring"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpc_endpoints.id,
  ]
  subnet_ids = module.high_availability_vpc.private_subnet_ids
}

#
# PrivateLink endpoint to SQS
#

resource "aws_vpc_endpoint" "sqs" {
  vpc_id              = module.high_availability_vpc.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${var.region}.sqs"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpc_endpoints.id,
  ]
  subnet_ids = module.high_availability_vpc.private_subnet_ids
}
