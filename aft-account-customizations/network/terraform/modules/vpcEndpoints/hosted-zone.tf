## CREATE VPC ENDPOINT HOSTED ZONES ##
resource "aws_route53_zone" "vpce_zone" {
  #checkov:skip=CKV2_AWS_38:This is a private hosted zone and DNSSEC can't be configured for private hosted zones
  #checkov:skip=CKV2_AWS_39:It is not possible create a query log for private hosted zone
  #\\052 to * terraform loop -> https://github.com/hashicorp/terraform-provider-aws/issues/10843
  for_each = local.hosted_zones
  name     = format("%s.%s.amazonaws.com", lookup(each.value, "service", []), lookup(each.value, "region", data.aws_region.hosted_zone_region.name))
  vpc {
    vpc_id     = var.vpc_shared_id
    vpc_region = data.aws_region.hosted_zone_region.name
  }
  lifecycle {
    ignore_changes = [ vpc ]
  }
  tags = {
    Name  = format("%s", lookup(each.value, "service", []))
    type  = "vpce"
  }
}

## CREATE VPC ENDPOINT HOSTED ZONES - RECORDS ##
resource "aws_route53_record" "this" {
  for_each = local.hosted_zones
  zone_id  = aws_route53_zone.vpce_zone[data.aws_vpc_endpoint_service.interfaces[each.key].service].zone_id
  name     = ""
  type     = "A"
  alias {
    name                   = aws_vpc_endpoint.this[data.aws_vpc_endpoint_service.interfaces[each.key].service].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.this[data.aws_vpc_endpoint_service.interfaces[each.key].service].dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }
}

## CREATE SSM PARAMETER WITH VPC_ENDPOINTS ##
resource "aws_ssm_parameter" "vpc_endpoints" {
  name  = "/aft/network/vpc/vpc_endpoints"
  type  = "String"
  value = local.vpc_endpoints
}