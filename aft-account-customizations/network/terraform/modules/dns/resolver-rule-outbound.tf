## CREATE RESOLVER RULES FOR INTERNAL DOMAINS ##
resource "aws_route53_resolver_rule" "internal_domains" {
  for_each             = toset(local.internal_domains)
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.resolver_outbound.id
  domain_name =  each.value
  name        = replace(each.value,".","_")

  dynamic "target_ip" {
    for_each = local.onprem_dns_servers
    content {
      ip   = target_ip.value
      port = local.dns_port
    }
  }
  tags = {
    "Name" = format("%s-%s-resolver-rule", var.project, replace(each.value,".","_"))
  }
}

## CREATE DEFAULT RESOLVER RULE ##
resource "aws_route53_resolver_rule" "default" {
  domain_name          = "."
  name                 = "default"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.resolver_outbound.id

  dynamic "target_ip" {
    for_each  = var.cisco_umbrella_ips
    content {
      ip = target_ip.value
    }
  }
  tags = {
    "Name" = format("%s-%s-resolver-rule", var.project, "default")
  }
}

## ASSOCIATE RESOLVER RULES ##
resource "aws_route53_resolver_rule_association" "internal_domains" {
  for_each         = aws_route53_resolver_rule.internal_domains
  resolver_rule_id = aws_route53_resolver_rule.internal_domains[each.key].id
  vpc_id = var.vpc_dns_id
}

resource "aws_route53_resolver_rule_association" "default" {
  resolver_rule_id = aws_route53_resolver_rule.default.id
  vpc_id           = var.vpc_dns_id
}

## SHARE RESOLVER RULES ##
resource "aws_ram_resource_share" "dns" {
  name                      = "ram-dns-${var.project}"
  allow_external_principals = false

  tags = {
    "Name" = "ram-dns-${var.project}"
  }
}

resource "aws_ram_principal_association" "dns" {
  principal          = data.aws_organizations_organization.this.arn
  resource_share_arn = aws_ram_resource_share.dns.arn
}

resource "aws_ram_resource_association" "internal_domains" {
  for_each         = aws_route53_resolver_rule.internal_domains
  resource_arn       = aws_route53_resolver_rule.internal_domains[each.key].arn
  resource_share_arn = aws_ram_resource_share.dns.arn
}

resource "aws_ram_resource_association" "default" {
  resource_arn       = aws_route53_resolver_rule.default.arn
  resource_share_arn = aws_ram_resource_share.dns.arn
}

## CREATE SSM PARAMETER ##
resource "aws_ssm_parameter" "resolver_rules" {
#checkov:skip=CKV_AWS_337: This parameter have not any sensitive information
#checkov:skip=CKV2_AWS_34: This parameter have not any sensitive information
  name  = "/aft/route53/rules/internal_domains"
  type  = "String"
  value = jsonencode(local.internal_domains)
}