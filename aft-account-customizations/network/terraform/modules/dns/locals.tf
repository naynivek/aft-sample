locals {
  dns_port = 53
  outbound_direction = "outbound"
  inbound_direction = "inbound"
  onprem_dns_servers = ["10.0.0.3",
                        "10.0.0.4"
                       ]
  internal_domains = [
                        "example.com"
                      ]
  outbound_allowed_resolvers = ["10.0.0.3/32","10.0.0.4/32","1.1.1.1/32"]
  inbound_allowed_resolvers = ["10.0.0.3/32","10.0.0.4/32"]
}