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
