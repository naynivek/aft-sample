## CREATE RULE ASSOCIATION WITH INTERNAL DOMAINS ##
resource "aws_route53_resolver_rule_association" "internal_domains" {
  count =  length(var.resolver_rules[*])
  resolver_rule_id = data.aws_route53_resolver_rule.internal_domains[count.index].id
  vpc_id           = var.vpc_id
}

## CREATE RULE ASSOCIATION WITH DEFAULT RULE ##
resource "aws_route53_resolver_rule_association" "default" {
  resolver_rule_id = data.aws_route53_resolver_rule.default.id
  vpc_id           = var.vpc_id
}
