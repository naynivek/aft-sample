## CREATE SECURITY GROUP FOR OUTBOUND RESOLVER ENDPOINT ##
resource "aws_security_group" "resolver_outbound" {
  name_prefix = "resolver_outbound"
  tags = {
    "Name" = "dns-sg-${var.project}"
  }
  vpc_id      = var.vpc_dns_id

  lifecycle {
    create_before_destroy = true
  }
  description = "SG for DNS resolver_outbound"
}

resource "aws_security_group_rule" "outbound_dns_udp" {
  type              = local.outbound_direction == "inbound" ? "ingress" : "egress"
  from_port         = local.dns_port
  to_port           = local.dns_port
  protocol          = "udp"
  cidr_blocks       = local.outbound_allowed_resolvers
  security_group_id = aws_security_group.resolver_outbound.id
  description       = "Allowing UDP - ${local.dns_port} to the private forwarders"
}

resource "aws_security_group_rule" "outbound_dns_tcp" {
  type              = local.outbound_direction == "inbound" ? "ingress" : "egress"
  from_port         = local.dns_port
  to_port           = local.dns_port
  protocol          = "tcp"
  cidr_blocks       = local.outbound_allowed_resolvers
  security_group_id = aws_security_group.resolver_outbound.id
  description       = "Allowing TCP - ${local.dns_port} to the private forwarders"
}

## CREATE OUTBOUND RESOLVER ENDPOINT ##
resource "aws_route53_resolver_endpoint" "resolver_outbound" {
  direction          = upper(local.outbound_direction)
  security_group_ids = [aws_security_group.resolver_outbound.id]
  name               = "dns-resolver-outbound-${var.project}"
  tags = {
    "Name" = "dns-resolver-outbound-${var.project}"
  }
  dynamic "ip_address" {
    for_each = var.subnet_dns_list
    content {
        subnet_id = ip_address.value.id
        ip        = cidrhost(ip_address.value.cidr_block, 10)
    }
  }
}
