data "aws_availability_zones" "available" {
  state = "available"
}

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
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = var.subnet_cidr_block

  tags = {
    Name    = "${var.project_name}-subnet"
    Project = var.project_name
    Billing = "Operations"
  }
}
