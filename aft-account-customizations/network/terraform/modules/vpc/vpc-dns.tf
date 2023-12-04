## CREATE VPC DNS ##
resource "aws_vpc" "dns_vpc" {
  cidr_block           = local.dns_vpc[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "dns-${var.project}"
  }
}

resource "aws_default_security_group" "dns_default" {
  vpc_id = aws_vpc.dns_vpc.id
}

resource "aws_flow_log" "dns_flow_log" {
  log_destination_type = "s3"
  log_destination = var.bucket_logs_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.dns_vpc.id
  log_format      = local.custom_log_format_v5
}

## CREATE DNS SUBNET - TGW ##
resource "aws_subnet" "dns_tgw" {
  count             = length(local.dns_tgw_subnets[*])
  vpc_id            = aws_vpc.dns_vpc.id
  cidr_block        = local.dns_tgw_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "dns-tgw-${element(local.azs[*], count.index)}"
  }
}

## CREATE DNS SUBNET - DNS ##
resource "aws_subnet" "dns" {
  count             = length(local.dns_subnets[*])
  vpc_id            = aws_vpc.dns_vpc.id
  cidr_block        = local.dns_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "dns-${element(local.azs[*], count.index)}"
  }
}

## CREATE INTERNAL ROUTE TABLE ##
resource "aws_route_table" "dns_internal" {
  count  = length(aws_subnet.outbound_tgw[*].id)
  vpc_id = aws_vpc.dns_vpc.id
  tags = {
    Name = "dns-internal-rtb-${aws_subnet.outbound_tgw[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "dns_tgw" {
  count          = length(aws_subnet.dns_tgw[*].id)
  subnet_id      = element(aws_subnet.dns_tgw[*].id, count.index)
  route_table_id = aws_route_table.dns_internal[count.index].id
}

resource "aws_route_table_association" "dns" {
  count          = length(aws_subnet.dns[*].id)
  subnet_id      = element(aws_subnet.dns[*].id, count.index)
  route_table_id = aws_route_table.dns_internal[count.index].id
}

resource "aws_route" "internal_rtb_dns_internal_net" {
  count          = length(aws_subnet.dns_tgw[*].id)
  route_table_id         = aws_route_table.dns_internal[count.index].id
  destination_cidr_block = var.cidr_block_sum
  transit_gateway_id     = var.tg_id
}

resource "aws_route" "internal_rtb_dns_internal_default" {
  count          = length(aws_subnet.dns_tgw[*].id)
  route_table_id         = aws_route_table.dns_internal[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.tg_id
}

## CREATE TRANSIT GATEWAY ATTACHMENT ##
resource "aws_ec2_transit_gateway_vpc_attachment" "dns_tgvpc" {
  subnet_ids                                      = aws_subnet.dns_tgw[*].id
  transit_gateway_id                              = var.tg_id
  vpc_id                                          = aws_vpc.dns_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  lifecycle {
    ignore_changes = [
      transit_gateway_default_route_table_association,
      transit_gateway_default_route_table_propagation
    ]
  }
  tags = {
    "Name" = "vpc-${var.project}-${var.environment}-dns-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "dns_rta" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dns_tgvpc.id
  transit_gateway_route_table_id = var.rtb_shrd_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "dns_rtp" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dns_tgvpc.id
  transit_gateway_route_table_id = var.rtb_shrd_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "dns_rtp_outbound" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dns_tgvpc.id
  transit_gateway_route_table_id = var.rtb_out_id
}
