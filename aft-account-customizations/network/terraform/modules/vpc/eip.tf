## CREATE OUTBOUND ELASTIC IP ADDRESS FOR NAT GATEWAYS ##
resource "aws_eip" "outbound_eip" {
  #checkov:skip=CKV2_AWS_19:These elastic ips are allocated to a Net Gateway, not an specific EC2 Instance
  count     = length(local.outbound_public_subnets[*])
  domain   = "vpc"
  tags = {
    Name = "outbound-eip-nat-${element(local.azs[*], count.index)}"
  }
}

## CREATE INBOUND ELASTIC IP ADDRESS FOR NAT GATEWAYS ##
resource "aws_eip" "inbound_eip" {
  #checkov:skip=CKV2_AWS_19:These elastic ips are allocated to a Net Gateway, not an specific EC2 Instance
  count     = length(local.inbound_public_subnets[*])
  domain   = "vpc"
  tags = {
    Name = "inbound-eip-nat-${element(local.azs[*], count.index)}"
  }
}