## CREATE INBOUND TRANSIT GATEWAY ROUTE TABLE ##
resource "aws_ec2_transit_gateway_route_table" "in" {
  transit_gateway_id = aws_ec2_transit_gateway.tg.id
  tags = {
    "Name" = "inbound-route-table"
  }
}