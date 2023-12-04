data "aws_ssm_parameter" "cidr_block" {
  name = "/aft/account-request/custom-fields/cidr_block"
}

data "aws_ssm_parameter" "environment" {
  name = "/aft/account-request/custom-fields/environment"
}

data "aws_ssm_parameter" "project" {
  name = "/aft/account-request/custom-fields/project"
}

data "aws_ssm_parameter" "region" {
  name = "/aft/account-request/custom-fields/region"
}

data "aws_ssm_parameter" "vpc_endpoints" {
  provider = aws.network
  name = "/aft/network/vpc/vpc_endpoints"
}

data "aws_ssm_parameter" "vpc_endpoints-sa" {
  provider = aws.network-sa
  name = "/aft/network/vpc/vpc_endpoints"
}

data "aws_ssm_parameter" "resolver_rules" {
  provider = aws.network
  name = "/aft/route53/rules/internal_domains"
}

data "aws_s3_bucket" "bucket_centralized_logs" {
  provider = aws.log
  bucket = "vpc-flow-logs-centralized-default"
}