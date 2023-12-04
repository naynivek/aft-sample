data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_caller_identity" "network" {
  provider = aws.network
}

data "aws_ec2_transit_gateway" "this" {
  provider = aws.network
  filter {
    name   = "owner-id"
    values = [data.aws_caller_identity.network.account_id]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_ec2_transit_gateway_route_table" "prd" {
  provider = aws.network
  filter {
    name   = "tag:Name"
    values = ["prd-route-table"]
  }
}

data "aws_ec2_transit_gateway_route_table" "outbound" {
  provider = aws.network
  filter {
    name   = "tag:Name"
    values = ["outbound-route-table"]
  }
}

data "aws_ec2_transit_gateway_route_table" "inbound" {
  provider = aws.network
  filter {
    name   = "tag:Name"
    values = ["inbound-route-table"]
  }
}

data "aws_route53_zone" "vpc_endpoints" {
  provider = aws.network
  count =  length(var.vpc_endpoints[*])
  name         = format("%s.%s.amazonaws.com", element(var.vpc_endpoints[*], count.index), data.aws_region.current.name)
  private_zone = true
}

data "aws_route53_zone" "phz_prd" {
  provider = aws.network
  name         = "prd.aws.oi"
  private_zone = true
}

data "aws_route53_zone" "phz_nprd" {
  provider = aws.network
  name         = "nprd.aws.oi"
  private_zone = true
}