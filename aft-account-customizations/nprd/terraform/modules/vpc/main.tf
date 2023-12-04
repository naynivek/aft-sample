## CREATE VPC ##
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "vpc-${var.project}"
  }
}

## CREATE VPC - SG ##
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
}

## CREATE VPC - FLOWLOG ##
resource "aws_flow_log" "this" {
  log_destination_type = "s3"
  log_destination = var.bucket_logs_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
  log_format      = local.custom_log_format_v5
}

## CREATE SUBNET - TGW ##
resource "aws_subnet" "tgw" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.tgw_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "tgw-${element(local.azs[*], count.index)}"
  }
}

## CREATE SUBNET - BACKEND ##
resource "aws_subnet" "backend" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.backend_subnet[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "backend-${element(local.azs[*], count.index)}"
  }
}

## CREATE SUBNET - DATABASE ##
resource "aws_subnet" "database" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.database_subnet[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "database-${element(local.azs[*], count.index)}"
  }
}

## CREATE EXTERNAL ROUTE TABLE ##
resource "aws_route_table" "this_external" {
  count  = length(aws_subnet.tgw[*].id)
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "external-rtb-${aws_subnet.tgw[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "tgw_external" {
  count          = length(aws_subnet.tgw[*].id)
  subnet_id      = element(aws_subnet.tgw[*].id, count.index)
  route_table_id = aws_route_table.this_external[count.index].id
}

resource "aws_route_table_association" "backend_external" {
  count          = length(aws_subnet.backend[*].id)
  subnet_id      = element(aws_subnet.backend[*].id, count.index)
  route_table_id = aws_route_table.this_external[count.index].id
}

resource "aws_route" "default_route" {
  count          = length(aws_subnet.backend[*].id)
  route_table_id         = aws_route_table.this_external[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ec2_transit_gateway.this.id
  depends_on = [ aws_ec2_transit_gateway_vpc_attachment.this ]
}

## CREATE TRANSIT GATEWAY ATTACHMENT ##
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  subnet_ids                                      = aws_subnet.tgw[*].id
  transit_gateway_id                              = data.aws_ec2_transit_gateway.this.id
  vpc_id                                          = aws_vpc.this.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  appliance_mode_support = "enable"
  lifecycle {
    ignore_changes = [
      transit_gateway_default_route_table_association,
      transit_gateway_default_route_table_propagation
    ]
  }
  tags = {
    "Name" = "vpc-${var.project}-${var.environment}-attach"
  }
  depends_on = [ aws_ram_resource_association.toNetwork ]
}

resource "aws_ec2_tag" "attach_tags" {
  provider    = aws.network
  resource_id = aws_ec2_transit_gateway_vpc_attachment.this.id
  key         = "Name"
  value       = "vpc-${var.project}-${var.environment}-attach"
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  provider                       = aws.network
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.nprd.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  provider                       = aws.network
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.nprd.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this_outbound" {
  provider                       = aws.network
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.outbound.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this_inbound" {
  provider                       = aws.network
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.inbound.id
}

## CREATE DNS ZONE ASSOCIATION FOR VPC ENDPOINTS ##
resource "aws_route53_vpc_association_authorization" "this_vpce" {
  provider                       = aws.network
  count =  length(var.vpc_endpoints[*])
  vpc_id  = aws_vpc.this.id
  zone_id = data.aws_route53_zone.vpc_endpoints[count.index].zone_id
}

resource "aws_route53_zone_association" "this_vpce" {
  count =  length(var.vpc_endpoints[*])
  zone_id = data.aws_route53_zone.vpc_endpoints[count.index].zone_id
  vpc_id  = aws_vpc.this.id
  depends_on = [ aws_route53_vpc_association_authorization.this_vpce ]
}

## CREATE DNS ZONE ASSOCIATION FOR WORKLOADS ##
resource "aws_route53_vpc_association_authorization" "this_workloads_nprd" {
  provider                       = aws.network
  vpc_id  = aws_vpc.this.id
  zone_id = data.aws_route53_zone.phz_nprd.id
}

resource "aws_route53_zone_association" "this_workloads_nprd" {
  zone_id = data.aws_route53_zone.phz_nprd.id
  vpc_id  = aws_vpc.this.id
  depends_on = [ aws_route53_vpc_association_authorization.this_workloads_nprd ]
}