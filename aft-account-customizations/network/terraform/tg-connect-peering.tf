## CREATE TG PEERING ##
resource "aws_ec2_transit_gateway_peering_attachment" "sa_to_us" {
  peer_account_id         = module.tg_sa.transit_gateway_owner_id
  peer_region             = data.aws_region.sa.name
  peer_transit_gateway_id = module.tg_sa.transit_gateway_id
  transit_gateway_id      = module.tg_us.transit_gateway_id

  tags = {
    Name = "tgw-peering-sa-east-1-TO-us-east-1"
  }
  depends_on = [ module.tg_sa, module.tg_us ]
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "sa_to_us" {
  provider = aws.sa
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.sa_to_us.id

  tags = {
    Name = "twg-peering-accepter"
  }
  depends_on = [ aws_ec2_transit_gateway_peering_attachment.sa_to_us ]
}


## TIME UNTIL TRANSIT GATEWAY PEERING FINISHES ##
resource "time_sleep" "wait_60_seconds" {
  create_duration = "60s"
  depends_on = [ aws_ec2_transit_gateway_peering_attachment_accepter.sa_to_us ]
}

## CREATE PEERING ROUTES TABLE - US ##

resource "aws_ec2_transit_gateway_route_table" "peering_rtb_us" {
  transit_gateway_id = module.tg_us.transit_gateway_id
  tags = {
    "Name" = "tg-peering-route-table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_us_rta" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.sa_to_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_rtb_us.id
  depends_on = [ time_sleep.wait_60_seconds ]
}

resource "aws_ec2_transit_gateway_route" "peering_us_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc_us.aws_ec2_transit_gateway_vpc_att_outbound
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_rtb_us.id
}

## CREATE PEERING ROUTES TABLE - SA ##

resource "aws_ec2_transit_gateway_route_table" "peering_rtb_sa" {
  provider = aws.sa
  transit_gateway_id = module.tg_sa.transit_gateway_id
  tags = {
    "Name" = "tg-peering-route-table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "peering_sa_rta" {
  provider = aws.sa
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.sa_to_us.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_rtb_sa.id
  depends_on = [ time_sleep.wait_60_seconds ]
}

resource "aws_ec2_transit_gateway_route" "peering_sa_default" {
  provider = aws.sa
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.vpc_sa.aws_ec2_transit_gateway_vpc_att_outbound
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.peering_rtb_sa.id
}

### UPDATE ROUTES US ##
resource "aws_ec2_transit_gateway_route" "outbound_us_to_sa" {
  destination_cidr_block         = data.aws_ssm_parameter.cidr_block_sum_sa.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.sa_to_us.id
  transit_gateway_route_table_id = module.tg_us.route_table_outbound
  depends_on = [ time_sleep.wait_60_seconds ]
}

### UPDATE ROUTES SA ##
resource "aws_ec2_transit_gateway_route" "outbound_sa_to_us" {
  provider = aws.sa
  destination_cidr_block         = data.aws_ssm_parameter.cidr_block_sum_us.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.sa_to_us.id
  transit_gateway_route_table_id = module.tg_sa.route_table_outbound
  depends_on = [ time_sleep.wait_60_seconds ]
}
