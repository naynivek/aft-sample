locals {
  azs                   = formatlist("${data.aws_region.current.name}%s", ["a", "b"])
  outbound_vpc          = slice(cidrsubnets(var.cidr_block, 2,2,2,2),0,1)
  inbound_vpc          = slice(cidrsubnets(var.cidr_block, 2,2,2,2),1,2)
  shared_vpc          = slice(cidrsubnets(var.cidr_block, 2,2,2,2),2,3)
  dns_vpc          = slice(cidrsubnets(var.cidr_block, 2,2,2,2),3,4)
  outbound_public_subnets = slice(cidrsubnets(local.outbound_vpc[0], 4,4,4),1,3)
  outbound_tgw_subnets =  slice(cidrsubnets(local.outbound_vpc[0], 1,4,4),1,3)
  outbound_fw_subnets = slice(cidrsubnets(local.outbound_vpc[0], 1,4,4,4,4),3,5)
  inbound_public_subnets = slice(cidrsubnets(local.inbound_vpc[0], 4,4,4),1,3)
  inbound_tgw_subnets =  slice(cidrsubnets(local.inbound_vpc[0], 1,4,4),1,3)
  inbound_fw_subnets = slice(cidrsubnets(local.inbound_vpc[0], 1,4,4,4,4),3,5)
  shared_vpce_subnets = slice(cidrsubnets(local.shared_vpc[0], 2,2),0,2)
  shared_tgw_subnets = slice(cidrsubnets(local.shared_vpc[0], 1,4,4),1,3)
  shared_ad_subnets     = slice(cidrsubnets(local.shared_vpc[0], 1,4,4,4,4),3,5)
  dns_subnets = slice(cidrsubnets(local.dns_vpc[0], 3,3),0,2)
  dns_tgw_subnets = slice(cidrsubnets(local.dns_vpc[0], 1,4,4),1,3)
  custom_log_format_v5 = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
}
