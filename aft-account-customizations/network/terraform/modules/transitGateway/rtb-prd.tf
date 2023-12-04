## CREATE PRD TRANSIT GATEWAY ROUTE TABLE ##
resource "aws_ec2_transit_gateway_route_table" "prd" {
  transit_gateway_id = aws_ec2_transit_gateway.tg.id
  tags = {
    "Name" = "prd-route-table"
  }
}

resource "aws_ec2_transit_gateway_route" "prd_internet" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.outbound_tgvpc_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prd.id
}