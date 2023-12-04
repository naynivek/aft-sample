## CREATE RAM TO SHARE THIS VPC WITH NETWORK ACCOUNT ##
resource "aws_ram_resource_share" "toNetwork" {
  name                      = "vpc-ram-${var.project}"
  allow_external_principals = false

  tags = {
    "Name" = "vpc-ram-${var.project}"
  }
}

resource "aws_ram_principal_association" "toNetwork" {
  principal          = data.aws_caller_identity.network.account_id
  resource_share_arn = aws_ram_resource_share.toNetwork.arn
}

resource "aws_ram_resource_association" "toNetwork" {
  count             = 2
  resource_arn       = element(aws_subnet.tgw[*].arn, count.index)
  resource_share_arn = aws_ram_resource_share.toNetwork.arn
}
