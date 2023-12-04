## CREATE SECURITY GROUP FOR INBOUND RESOLVER ENDPOINT ##
resource "aws_security_group" "resolver_inbound" {
  name_prefix = "resolver_inbound"
  tags = {
    "Name" = "dns-sg-${var.project}"
  }
  vpc_id      = var.vpc_dns_id

  lifecycle {
    create_before_destroy = true
  }
  description = "SG for DNS resolver_inbound"
}

resource "aws_security_group_rule" "inbound_dns_udp" {
  type              = local.inbound_direction == "inbound" ? "ingress" : "egress"
  from_port         = local.dns_port
  to_port           = local.dns_port
  protocol          = "udp"
  cidr_blocks       = local.inbound_allowed_resolvers
  security_group_id = aws_security_group.resolver_inbound.id
  description       = "Allowing UDP - ${local.dns_port} to the private forwarders"
}

resource "aws_security_group_rule" "inbound_dns_tcp" {
  type              = local.inbound_direction == "inbound" ? "ingress" : "egress"
  from_port         = local.dns_port
  to_port           = local.dns_port
  protocol          = "tcp"
  cidr_blocks       = local.inbound_allowed_resolvers
  security_group_id = aws_security_group.resolver_inbound.id
  description       = "Allowing TCP - ${local.dns_port} to the private forwarders"
}

## CREATE INBOUND RESOLVER ENDPOINT  ##
resource "aws_route53_resolver_endpoint" "resolver_inbound" {
  direction          = upper(local.inbound_direction)
  security_group_ids = [aws_security_group.resolver_inbound.id]
  name               = "dns-resolver-inbound-${var.project}"
  tags = {
    "Name" = "dns-resolver-inbound-${var.project}"
  }
  dynamic "ip_address" {
    for_each = var.subnet_dns_list
    content {
        subnet_id = ip_address.value.id
        ip        = cidrhost(ip_address.value.cidr_block, 11)
    }
  }
}



