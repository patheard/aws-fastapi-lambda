data "aws_availability_zones" "available" {
  state = "available"
}

#
# VPC and subnet
#

resource "aws_vpc" "api_vpc" {
  cidr_block                       = var.vpc_cidr_block
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
    Billing = "Operations"
  }
}

resource "aws_subnet" "api_subnet" {
  vpc_id            = aws_vpc.api_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 0)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name    = "${var.project_name}-subnet"
    Project = var.project_name
    Billing = "Operations"
  }
}

#
# Security groups
#

resource "aws_default_security_group" "vpc_default" {
  vpc_id      = aws_vpc.api_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "VpcEndpoints"
  description = "VPC Endpoint security group"
  vpc_id      = aws_vpc.api_vpc.id
}

resource "aws_security_group" "lambda_security_group" {
  name        = "Lambda"
  description = "Allow TLS outbound traffic to CloudWatch from the Lambda"
  vpc_id      = aws_vpc.api_vpc.id
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
  description              = "Security group rule for egress to "
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_security_group.id
  source_security_group_id = aws_security_group.vpc_endpoints.id
}

#
# Network Access Control List (NACL)
# Block SSH and RDP ports, open everything else
#

resource "aws_default_network_acl" "vpc_default" {
  default_network_acl_id  = aws_vpc.api_vpc.default_network_acl_id
  subnet_ids              = [aws_subnet.api_subnet.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    to_port    = 3389
  }

  ingress {
    protocol   = -1
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

#
# PrivateLink endpoints to CloudWatch logs/monitoring
#

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.api_vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${var.region}.logs"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpc_endpoints.id,
  ]
  subnet_ids = aws_subnet.api_subnet.*.id
}

resource "aws_vpc_endpoint" "monitoring" {
  vpc_id              = aws_vpc.api_vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${var.region}.monitoring"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.vpc_endpoints.id,
  ]
  subnet_ids = aws_subnet.api_subnet.*.id
}