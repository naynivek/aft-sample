resource "aws_ec2_transit_gateway_route_table" "vpn" {
  transit_gateway_id = aws_ec2_transit_gateway.tg.id
  tags = {
    "Name" = "vpn-route-table"
  }
}