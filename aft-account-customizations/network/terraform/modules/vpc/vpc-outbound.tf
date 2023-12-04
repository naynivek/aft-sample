## CREATE VPC OUTBOUND ##
resource "aws_vpc" "outbound_vpc" {
  cidr_block           = local.outbound_vpc[0]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "outbound-${var.project}"
  }
}

resource "aws_default_security_group" "outbound_default" {
  vpc_id = aws_vpc.outbound_vpc.id
}

resource "aws_flow_log" "outbound_flow_log" {
  log_destination_type = "s3"
  log_destination = var.bucket_logs_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.outbound_vpc.id
  log_format      = local.custom_log_format_v5
}



## CREATE OUTBOUND SUBNET - TGW ##
resource "aws_subnet" "outbound_tgw" {
  count             = length(local.outbound_tgw_subnets[*])
  vpc_id            = aws_vpc.outbound_vpc.id
  cidr_block        = local.outbound_tgw_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "outbound-tgw-${element(local.azs[*], count.index)}"
  }
}

## CREATE OUTBOUND SUBNET - FIREWALL ##
resource "aws_subnet" "outbound_fw" {
  count             = length(local.outbound_fw_subnets[*])
  vpc_id            = aws_vpc.outbound_vpc.id
  cidr_block        = local.outbound_fw_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "outbound-fw-${element(local.azs[*], count.index)}"
  }
}


## CREATE OUTBOUND SUBNET - PUBLIC + IGW + NAT ##
resource "aws_subnet" "outbound_public" {
  count             = length(local.outbound_public_subnets[*])
  vpc_id            = aws_vpc.outbound_vpc.id
  cidr_block        = local.outbound_public_subnets[count.index]
  availability_zone = element(local.azs[*], count.index)

  tags = {
    Name = "outbound-public-${element(local.azs[*], count.index)}"
  }
}

resource "aws_internet_gateway" "outbound_igw" {
  vpc_id = aws_vpc.outbound_vpc.id

  tags = {
    Name = "outbound_igw-${var.project}"
  }
}

resource "aws_nat_gateway" "outbound_nat" {
  count     = length(local.outbound_public_subnets[*])
  subnet_id = aws_subnet.outbound_public[count.index].id
  allocation_id = aws_eip.outbound_eip[count.index].id
  depends_on = [ aws_internet_gateway.outbound_igw ]
  tags = {
    Name = "outbound_nat-${var.project}-${aws_subnet.outbound_tgw[count.index].availability_zone}"
  }
}


## CREATE TGW ROUTE TABLE #
resource "aws_route_table" "outbound_tgw" {
  count  = length(aws_subnet.outbound_tgw[*].id)
  vpc_id = aws_vpc.outbound_vpc.id
  tags = {
    Name = "outbound-tgw-rtb-${aws_subnet.outbound_tgw[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "outbound_tgw" {
  count          = length(aws_subnet.outbound_tgw[*].id)
  subnet_id      = element(aws_subnet.outbound_tgw[*].id, count.index)
  route_table_id = aws_route_table.outbound_tgw[count.index].id
}

resource "aws_route" "outbound_tgw_default_fw" {
  count          = length(aws_subnet.outbound_tgw[*].id)
  route_table_id         = aws_route_table.outbound_tgw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id = var.net_fw_id_azs[aws_subnet.outbound_tgw[count.index].availability_zone]
}

## CREATE FW ROUTE TABLE ##
resource "aws_route_table" "outbound_fw" {
  count  = length(aws_subnet.outbound_fw[*].id)
  vpc_id = aws_vpc.outbound_vpc.id
  tags = {
    Name = "outbound-fw-rtb-${aws_subnet.outbound_fw[count.index].availability_zone}"
  }
}

resource "aws_route_table_association" "outbound_fw" {
  count          = length(aws_subnet.outbound_fw[*].id)
  subnet_id      = element(aws_subnet.outbound_fw[*].id, count.index)
  route_table_id = aws_route_table.outbound_fw[count.index].id
}

resource "aws_route" "outbound_fw_default_nat" {
  count          = length(aws_subnet.outbound_tgw[*].id)
  route_table_id         = aws_route_table.outbound_fw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.outbound_nat[count.index].id
}

resource "aws_route" "internal_rtb_outbound_fw_net" {
  count          = length(aws_subnet.outbound_fw[*].id)
  route_table_id         = aws_route_table.outbound_fw[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tg_id
}

## CREATE EXTERNAL ROUTE TABLE ##
resource "aws_route_table" "outbound_external" {
  vpc_id = aws_vpc.outbound_vpc.id
  tags = {
    Name = "outbound-external-rtb"
  }
}

resource "aws_route_table_association" "outbound_public" {
  count          = length(aws_subnet.outbound_public[*].id)
  subnet_id      = element(aws_subnet.outbound_public[*].id, count.index)
  route_table_id = aws_route_table.outbound_external.id
}


resource "aws_route" "outbound_default_igw" {
  route_table_id         = aws_route_table.outbound_external.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.outbound_igw.id
}

resource "aws_route" "external_rtb_outbound_internal_net" {
  route_table_id         = aws_route_table.outbound_external.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.tg_id
}


## CREATE TRANSIT GATEWAY ATTACHMENT ##
resource "aws_ec2_transit_gateway_vpc_attachment" "outbound_tgvpc" {
  subnet_ids                                      = aws_subnet.outbound_tgw[*].id
  transit_gateway_id                              = var.tg_id
  vpc_id                                          = aws_vpc.outbound_vpc.id
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
    "Name" = "vpc-${var.project}-${var.environment}-outbound-attach"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "outbound_rta" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.outbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_out_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "outbound_rtp" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.outbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_out_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "outbound_rtp_shared" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.outbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_shrd_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "outbound_rtp_prd" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.outbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_prd_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "outbound_rtp_nprd" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.outbound_tgvpc.id
  transit_gateway_route_table_id = var.rtb_nprd_id
}