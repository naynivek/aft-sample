## CREATE SG FOR VPC ENDPOINTS ##
resource "aws_security_group" "aft_vpc_endpoint_sg" {
  name        = "aft-endpoint-sg"
  description = "Allow inbound HTTPS traffic and all Outbound"
  vpc_id      = var.vpc_shared_id
  tags = {
    "Name" = "vpce-sg-${var.project}"
  }

  ingress {
    description = "Allow inbound TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description      = "Allow outbound traffic to internet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

## CREATE VPC ENDPOINTS ##
resource "aws_vpc_endpoint" "this" {
  for_each = var.endpoints
  vpc_id            = var.vpc_shared_id
  service_name      = data.aws_vpc_endpoint_service.interfaces[each.key].service_name
  vpc_endpoint_type = lookup(each.value, "service_type", "Interface")
  auto_accept       = lookup(each.value, "auto_accept", null)

  security_group_ids  = lookup(each.value, "service_type", "Interface") == "Interface" ? length(distinct(concat([aws_security_group.aft_vpc_endpoint_sg.id], lookup(each.value, "security_group_ids", [])))) > 0 ? distinct(concat([aws_security_group.aft_vpc_endpoint_sg.id], lookup(each.value, "security_group_ids", []))) : null : null
  subnet_ids          = lookup(each.value, "service_type", "Interface") == "Interface" ? distinct(concat(var.subnet_shared_list[*].id, lookup(each.value, "subnet_ids", []))) : null
  route_table_ids     = lookup(each.value, "service_type", "Interface") == "Gateway" ? lookup(each.value, "route_table_ids", null) : null
  policy              = lookup(each.value, "policy", null)
  private_dns_enabled = lookup(each.value, "service_type", "Interface") == "Interface" ? lookup(each.value, "private_dns_enabled", null) : null

  tags = {
        Name = format("%s-vpce-${var.project}", lookup(each.value, "service", []))
      }

  timeouts {
    create = lookup(var.timeouts, "create", "10m")
    update = lookup(var.timeouts, "update", "10m")
    delete = lookup(var.timeouts, "delete", "10m")
  }
}