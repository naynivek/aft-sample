## CREATE VPC INBOUND ##
resource "aws_vpc" "inbound_vpc" {
  cidr_block           = local.inbound_vpc[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "inbound-${var.project}"
  }
}

resource "aws_default_security_group" "inbound_default" {
  vpc_id = aws_vpc.inbound_vpc.id
}

resource "aws_flow_log" "inbound_flow_log" {
  log_destination_type = "s3"
  log_destination = var.bucket_logs_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.inbound_vpc.id
  log_format      = local.custom_log_format_v5
}

## CREATE INTBOUND SUBNET - TGW ##
resource "aws_subnet" "inbound_tgw" {
  count             = length(local.inbound_tgw_subnets[*])
  vpc_id            = aws_vpc.inbound_vpc.id
  cidr_block        = local.inbound_tgw_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "inbound-tgw-${element(local.azs[*], count.index)}"
  }
}

## CREATE INTBOUND SUBNET - FIREWALL ##
resource "aws_subnet" "inbound_fw" {
  count             = length(local.inbound_fw_subnets[*])
  vpc_id            = aws_vpc.inbound_vpc.id
  cidr_block        = local.inbound_fw_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "inbound-fw-${element(local.azs[*], count.index)}"
  }
}


## CREATE INTBOUND SUBNET - PUBLIC + IGW ##
resource "aws_subnet" "inbound_public" {
  count             = length(local.inbound_public_subnets[*])
  vpc_id            = aws_vpc.inbound_vpc.id
  cidr_block        = local.inbound_public_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "inbound-public-${element(local.azs[*], count.index)}"
  }
}

resource "aws_internet_gateway" "inbound_igw" {
  vpc_id = aws_vpc.inbound_vpc.id

  tags = {
    Name = "inbound_igw-${var.project}"
  }
}


## CREATE TGW ROUTE TABLE ##
resource "aws_route_table" "inbound_tgw" {
  count  = length(aws_subnet.outbound_tgw[*].id)
  vpc_id = aws_vpc.inbound_vpc.id
  tags = {
    Name = "inbound-tgw-rtb-${aws_subnet.outbound_tgw[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "inbound_tgw" {
  count          = length(aws_subnet.inbound_tgw[*].id)
  subnet_id      = element(aws_subnet.inbound_tgw[*].id, count.index)
  route_table_id = aws_route_table.inbound_tgw[count.index].id
}

resource "aws_route" "inbound_tgw_default_igw" {
  count          = length(aws_subnet.inbound_tgw[*].id)
  route_table_id         = aws_route_table.inbound_tgw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.inbound_igw.id
}

resource "aws_route" "internal_rtb_inbound_tgw_net" {
  count          = length(aws_subnet.inbound_tgw[*].id)
  route_table_id         = aws_route_table.inbound_tgw[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tg_id
}

## CREATE FW ROUTE TABLE ##
resource "aws_route_table" "inbound_fw" {
  count  = length(aws_subnet.outbound_fw[*].id)
  vpc_id = aws_vpc.inbound_vpc.id
  tags = {
    Name = "inbound-fw-rtb-${aws_subnet.outbound_fw[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "inbound_fw" {
  count          = length(aws_subnet.inbound_fw[*].id)
  subnet_id      = element(aws_subnet.inbound_fw[*].id, count.index)
  route_table_id = aws_route_table.inbound_fw[count.index].id
}

resource "aws_route" "inbound_fw_default_igw" {
  count          = length(aws_subnet.inbound_fw[*].id)
  route_table_id         = aws_route_table.inbound_fw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.inbound_igw.id
}

resource "aws_route" "internal_rtb_inbound_fw_net" {
  count          = length(aws_subnet.inbound_fw[*].id)
  route_table_id         = aws_route_table.inbound_fw[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tg_id
}


## CREATE EXTERNAL ROUTE TABLE ##
resource "aws_route_table" "inbound_external" {
  vpc_id = aws_vpc.inbound_vpc.id
  tags = {
    Name = "inbound-external-rtb"
  }
}

resource "aws_route_table_association" "inbound_public" {
  count          = length(aws_subnet.inbound_public[*].id)
  subnet_id      = element(aws_subnet.inbound_public[*].id, count.index)
  route_table_id = aws_route_table.inbound_external.id
}


resource "aws_route" "inbound_default_igw" {
  route_table_id         = aws_route_table.inbound_external.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.inbound_igw.id
}

resource "aws_route" "external_rtb_inbound_internal_net" {
  route_table_id         = aws_route_table.inbound_external.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tg_id
}


## CREATE TRANSIT GATEWAY ATTACHMENT ##
resource "aws_ec2_transit_gateway_vpc_attachment" "inbound_tgvpc" {
  subnet_ids                                      = aws_subnet.inbound_tgw[*].id
  transit_gateway_id                              = var.tg_id
  vpc_id                                          = aws_vpc.inbound_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  lifecycle {
    ignore_changes = [
      transit_gateway_default_route_table_association,
      transit_gateway_default_route_table_propagation
    ]
  }
  tags = {
    "Name" = "vpc-${var.project}-${var.environment}-inbound-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "inbound_rta" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_in_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "inbound_rtp" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_in_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "inbound_rtp_shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_shrd_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "inbound_rtp_prd" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_prd_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "inbound_rtp_nprd" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_nprd_id
}
