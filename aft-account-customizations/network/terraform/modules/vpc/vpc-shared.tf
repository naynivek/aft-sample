## CREATE VPC SHARED ##
resource "aws_vpc" "shared_vpc" {
  cidr_block           = local.shared_vpc[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "shared-${var.project}"
  }
}

resource "aws_default_security_group" "shared_default" {
  vpc_id = aws_vpc.shared_vpc.id
}

resource "aws_flow_log" "shared_flow_log" {
  log_destination_type = "s3"
  log_destination = var.bucket_logs_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.shared_vpc.id
  log_format      = local.custom_log_format_v5
}

## CREATE SHARED SUBNET - TGW ##
resource "aws_subnet" "shared_tgw" {
  count             = length(local.shared_tgw_subnets[*])
  vpc_id            = aws_vpc.shared_vpc.id
  cidr_block        = local.shared_tgw_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "shared-tgw-${element(local.azs[*], count.index)}"
  }
}

## CREATE SHARED SUBNET - AD ##
resource "aws_subnet" "shared_ad" {
  count             = length(local.shared_ad_subnets[*])
  vpc_id            = aws_vpc.shared_vpc.id
  cidr_block        = local.shared_ad_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "shared-ad-${element(local.azs[*], count.index)}"
  }
}


## CREATE SHARED SUBNET - VPCE ##
resource "aws_subnet" "shared_vpce" {
  count             = length(local.shared_vpce_subnets[*])
  vpc_id            = aws_vpc.shared_vpc.id
  cidr_block        = local.shared_vpce_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "shared-vpce-${element(local.azs[*], count.index)}"
  }
}

## CREATE INTERNAL ROUTE TABLE ##
resource "aws_route_table" "shared_internal" {
  count  = length(aws_subnet.outbound_tgw[*].id)
  vpc_id = aws_vpc.shared_vpc.id
  tags = {
    Name = "shared-internal-rtb-${aws_subnet.outbound_tgw[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "shared_tgw" {
  count          = length(aws_subnet.shared_tgw[*].id)
  subnet_id      = element(aws_subnet.shared_tgw[*].id, count.index)
  route_table_id = aws_route_table.shared_internal[count.index].id
}

resource "aws_route_table_association" "shared_ad" {
  count          = length(aws_subnet.shared_ad[*].id)
  subnet_id      = element(aws_subnet.shared_ad[*].id, count.index)
  route_table_id = aws_route_table.shared_internal[count.index].id
}

resource "aws_route_table_association" "shared_vpce" {
  count          = length(aws_subnet.shared_vpce[*].id)
  subnet_id      = element(aws_subnet.shared_vpce[*].id, count.index)
  route_table_id = aws_route_table.shared_internal[count.index].id
}


resource "aws_route" "internal_shared_default_tgw" {
  count          = length(aws_subnet.shared_tgw[*].id)
  route_table_id         = aws_route_table.shared_internal[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id = var.tg_id
}

resource "aws_route" "internal_rtb_shared_internal_net" {
  count          = length(aws_subnet.shared_tgw[*].id)
  route_table_id         = aws_route_table.shared_internal[count.index].id
  destination_cidr_block = var.cidr_block_sum
  transit_gateway_id     = var.tg_id
}

## CREATE TRANSIT GATEWAY ATTACHMENT ##
resource "aws_ec2_transit_gateway_vpc_attachment" "shared_tgvpc" {
  subnet_ids                                      = aws_subnet.shared_tgw[*].id
  transit_gateway_id                              = var.tg_id
  vpc_id                                          = aws_vpc.shared_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  lifecycle {
    ignore_changes = [
      transit_gateway_default_route_table_association,
      transit_gateway_default_route_table_propagation
    ]
  }
  tags = {
    "Name" = "vpc-${var.project}-${var.environment}-shared-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "shared_rta" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_tgvpc.id
  transit_gateway_route_table_id = var.rtb_shrd_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared_rtp" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_tgvpc.id
  transit_gateway_route_table_id = var.rtb_shrd_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared_rtp_outbound" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_tgvpc.id
  transit_gateway_route_table_id = var.rtb_out_id
}