locals {
  azs                   = formatlist("${data.aws_region.current.name}%s", ["a", "b"])
  tgw_subnets           = slice(cidrsubnets(var.cidr_block, 1,4,4),1,3)
  backend_subnet        = slice(cidrsubnets(var.cidr_block, 3,3),0,2)
  database_subnet       = slice(cidrsubnets(var.cidr_block, 3,3,3,3),2,4)
  custom_log_format_v5 = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
}