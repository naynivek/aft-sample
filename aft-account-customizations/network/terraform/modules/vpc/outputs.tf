output "aws_ec2_transit_gateway_vpc_att_outbound" {
  description = "Outbound VPC Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.outbound_tgvpc.id
}

output "aws_ec2_transit_gateway_vpc_att_inbound" {
  description = "Inbound VPC Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.inbound_tgvpc.id
}

output "aws_ec2_transit_gateway_vpc_att_shared" {
  description = "Shared VPC Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.shared_tgvpc.id
}

output "aws_ec2_transit_gateway_vpc_att_dns" {
  description = "DNS VPC Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.dns_tgvpc.id
}

output "vpc_dns_id" {
  description = "DNS VPC Attachment ID"
  value       = aws_vpc.dns_vpc.id
}

output "vpc_dns_subnets" {
  description = "DNS Subnets IDs"
  value       = aws_subnet.dns[*]
}

output "vpc_shared_id" {
  description = "Shared VPC Attachment ID"
  value       = aws_vpc.shared_vpc.id
}

output "vpc_shared_subnets" {
  description = "Shared  Subnets IDs"
  value       = aws_subnet.shared_vpce[*]
}

output "vpc_outbound_id" {
  description = "Outbound VPC ID"
  value       = aws_vpc.outbound_vpc.id
}

output "vpc_outbound_fw_subnets" {
  description = "Outbound Subnet IDs"
  value       = aws_subnet.outbound_fw[*].id
}