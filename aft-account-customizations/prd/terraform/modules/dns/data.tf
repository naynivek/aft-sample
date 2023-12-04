data "aws_route53_resolver_rule" "default" {
  provider = aws.network
  domain_name = "."
  rule_type   = "FORWARD"
}

data "aws_route53_resolver_rule" "internal_domains" {
  provider = aws.network
  count =  length(var.resolver_rules[*])
  domain_name = format("%s", element(var.resolver_rules[*], count.index))
  rule_type   = "FORWARD"
}
