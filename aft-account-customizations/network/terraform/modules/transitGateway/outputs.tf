output "transit_gateway_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.tg.id
}

output "transit_gateway_owner_id" {
  description = "Transit Gateway Owner ID"
  value       = aws_ec2_transit_gateway.tg.owner_id
}

output "route_table_shared" {
  description = "Shared Route Table ID"
  value       = aws_ec2_transit_gateway_route_table.shrd.id
}

output "route_table_outbound" {
  description = "Outbound Table ID"
  value       = aws_ec2_transit_gateway_route_table.out.id
}

output "route_table_inbound" {
  description = "Inbound Table ID"
  value       = aws_ec2_transit_gateway_route_table.in.id
}

output "route_table_nprd" {
  description = "Nprd Table ID"
  value       = aws_ec2_transit_gateway_route_table.nprd.id
}

output "route_table_prd" {
  description = "Prd Table ID"
  value       = aws_ec2_transit_gateway_route_table.prd.id
}

output "route_table_vpn" {
  description = "VPN Table ID"
  value       = aws_ec2_transit_gateway_route_table.vpn.id
}

