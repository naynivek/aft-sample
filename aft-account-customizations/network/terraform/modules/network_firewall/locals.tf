locals {
  stateless_rule_group = [
    {
    capacity    = 100
    name        = "drop-icmp"
    description = "Drop ICMP packets"
    rule_config = [{
        priority              = 1
        protocols_number      = [1]
        source_ipaddress      = "0.0.0.0/0"
        destination_ipaddress = "0.0.0.0/0"
        actions = {
        type = "pass"
        }
    }]
    }
  ]
  fivetuple_stateful_rule_group = [
      {
      capacity    = 100
      name        = "drop-ext-dns"
      description = "Stateful rule drop external DNS resolution"
      rule_config = [{
          description           = "Drop DNS Rule"
          protocol              = "DNS"
          source_ipaddress      = "ANY"
          source_port           = "ANY"
          destination_ipaddress = "8.8.8.8"
          destination_port      = "ANY"
          direction             = "ANY"
          sid                   = "1"
          actions = {
          type = "alert"
          }
      }]
      },
  ]
  this_stateful_group_arn  = concat(aws_networkfirewall_rule_group.suricata_stateful_group[*].arn, aws_networkfirewall_rule_group.domain_stateful_group[*].arn, aws_networkfirewall_rule_group.fivetuple_stateful_group[*].arn, var.aws_managed_rule_group)
  this_stateless_group_arn = concat(aws_networkfirewall_rule_group.stateless_group[*].arn)
}