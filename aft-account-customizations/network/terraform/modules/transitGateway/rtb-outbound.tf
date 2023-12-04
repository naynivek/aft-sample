## CREATE OUTBOUND TRANSIT GATEWAY ROUTE TABLE ##
resource "aws_ec2_transit_gateway_route_table" "out" {
  transit_gateway_id = aws_ec2_transit_gateway.tg.id
  tags = {
    "Name" = "outbound-route-table"
  }
}

resource "aws_ec2_transit_gateway_route" "outbound_internet" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.outbound_tgvpc_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.out.id
}
