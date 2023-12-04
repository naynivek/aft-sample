## CREATE ROUTE53 PRD ZONE ##
resource "aws_route53_zone" "prd" {
  #checkov:skip=CKV2_AWS_39: Query log is not available for private zones
  #checkov:skip=CKV2_AWS_38: This module creates a private hosted zone, the vpc association is done right after
  name          = "prd.example.com"
  force_destroy = var.force_destroy
  vpc {
    vpc_id = var.vpc_dns_id_us
  }
  
  lifecycle {
    ignore_changes = [vpc]
  }
  tags = var.tags
}

## CREATE ROUTE53 NPRD ZONE ##
resource "aws_route53_zone" "nprd" {
  #checkov:skip=CKV2_AWS_39: Query log is not available for private zones
  #checkov:skip=CKV2_AWS_38: This module creates a private hosted zone, the vpc association is done right after
  name          = "nprd.example.com"
  force_destroy = var.force_destroy
  vpc {
    vpc_id = var.vpc_dns_id_us
  }
  lifecycle {
    ignore_changes = [vpc]
  }
  tags = var.tags
}

## CREATE SA ASSOCIATION WITH ZONES ##
resource "aws_route53_vpc_association_authorization" "sa_prd_auth" {
  vpc_id  = var.vpc_dns_id_sa
  zone_id = aws_route53_zone.prd.id
}

resource "aws_route53_zone_association" "sa_prd_ass" {
  provider = aws.sa
  vpc_id  = var.vpc_dns_id_sa
  zone_id = aws_route53_zone.prd.id
}

resource "aws_route53_vpc_association_authorization" "sa_nprd_auth" {
  vpc_id  = var.vpc_dns_id_sa
  zone_id = aws_route53_zone.nprd.id
}

resource "aws_route53_zone_association" "sa_nprd_ass" {
  provider = aws.sa
  vpc_id  = var.vpc_dns_id_sa
  zone_id = aws_route53_zone.nprd.id
}


