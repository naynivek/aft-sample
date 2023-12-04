## CREATE TRANSIT GATEWAY ##
resource "aws_ec2_transit_gateway" "tg" {
  #checkov:skip=CKV_AWS_331:For the sake of automation, the transtig gateway should accepct new VPC attachment automatically
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  amazon_side_asn                 = var.amazon_side_asn
  description                     = "${var.project} Transit Gateway"
  tags = {
    "Name" = "tgw-${var.project}-${data.aws_region.current.name}"
  }
}

## SHARE TRANSIT GATEWAY WITH ORG ##
resource "aws_ram_resource_share" "tg" {
  name                      = "ram-tgw-${var.project}"
  allow_external_principals = false

  tags = {
    "Name" = "ram-tgw-${var.project}-${data.aws_region.current.name}"
  }
}

resource "aws_ram_resource_association" "tg" {
  resource_arn       = aws_ec2_transit_gateway.tg.arn
  resource_share_arn = aws_ram_resource_share.tg.arn
}

resource "aws_ram_principal_association" "tg" {
  principal          = data.aws_organizations_organization.this.arn
  resource_share_arn = aws_ram_resource_share.tg.arn
}
