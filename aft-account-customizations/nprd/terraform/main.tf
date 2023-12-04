module "vpc" {
  count = local.region == "us-east-1" ? 1 : 0
  source = "./modules/vpc"
  cidr_block = data.aws_ssm_parameter.cidr_block.value
  project = data.aws_ssm_parameter.project.value
  environment = data.aws_ssm_parameter.environment.value
  vpc_endpoints = local.vpc_endpoints
  bucket_logs_arn = data.aws_s3_bucket.bucket_centralized_logs.arn
  providers = {
    aws.network = aws.network
  }
}

module "dns" {
  count = local.region == "us-east-1" ? 1 : 0
  source    = "./modules/dns"
  vpc_id    = module.vpc[0].vpc_id
  resolver_rules = local.resolver_rules
  providers = {
    aws.network = aws.network
  }
}

module "vpc_sa" {
  count = local.region == "sa-east-1" ? 1 : 0
  source = "./modules/vpc"
  cidr_block = data.aws_ssm_parameter.cidr_block.value
  project = data.aws_ssm_parameter.project.value
  environment = data.aws_ssm_parameter.environment.value
  vpc_endpoints = local.vpc_endpoints-sa
  bucket_logs_arn = data.aws_s3_bucket.bucket_centralized_logs.arn
  providers = {
    aws = aws.sa
    aws.network = aws.network-sa
  }
}

module "dns_sa" {
  count = local.region == "sa-east-1" ? 1 : 0
  source    = "./modules/dns"
  vpc_id    = module.vpc_sa[0].vpc_id
  resolver_rules = local.resolver_rules
  providers = {
    aws = aws.sa
    aws.network = aws.network-sa
  }
}

locals {
  vpc_endpoints = [ for i in split(",",nonsensitive(data.aws_ssm_parameter.vpc_endpoints.value)): trim(i,"[\"]") ]
  vpc_endpoints-sa = [ for i in split(",",nonsensitive(data.aws_ssm_parameter.vpc_endpoints-sa.value)): trim(i,"[\"]") ]
  resolver_rules = [ for i in split(",",nonsensitive(data.aws_ssm_parameter.resolver_rules.value)): trim(i,"[\"]") ]
  region = data.aws_ssm_parameter.region.value
}
