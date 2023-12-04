locals {
  hosted_zones = {
    for k, v in var.endpoints : k => v if v.service_type == "Interface"
  }
  vpc_endpoints = jsonencode([
    for k, v in local.hosted_zones : v.service
  ])
}