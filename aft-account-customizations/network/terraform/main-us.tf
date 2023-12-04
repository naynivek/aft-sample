module "tg_us" {
  amazon_side_asn       = "64513"
  source                = "./modules/transitGateway"
  project               = data.aws_ssm_parameter.project.value
  environment           = data.aws_ssm_parameter.environment.value
  outbound_tgvpc_id     = module.vpc_us.aws_ec2_transit_gateway_vpc_att_outbound
  inbound_tgvpc_id      = module.vpc_us.aws_ec2_transit_gateway_vpc_att_inbound
  shared_tgvpc_id       = module.vpc_us.aws_ec2_transit_gateway_vpc_att_shared
  dns_tgvpc_id          = module.vpc_us.aws_ec2_transit_gateway_vpc_att_dns
  cidr_block        = data.aws_ssm_parameter.cidr_block_us.value
}

module "vpc_us" {
  source = "./modules/vpc"
  cidr_block     = data.aws_ssm_parameter.cidr_block_us.value
  cidr_block_sum        = data.aws_ssm_parameter.cidr_block_sum_us.value
  outside_cidr_block_sum        = data.aws_ssm_parameter.cidr_block_sum_sa.value
  project                   = data.aws_ssm_parameter.project.value
  environment               = data.aws_ssm_parameter.environment.value
  tg_id                  = module.tg_us.transit_gateway_id
  rtb_shrd_id            = module.tg_us.route_table_shared
  rtb_out_id             = module.tg_us.route_table_outbound
  rtb_in_id              = module.tg_us.route_table_inbound
  rtb_nprd_id             = module.tg_us.route_table_nprd
  rtb_prd_id             = module.tg_us.route_table_prd
  net_fw_id_azs              = module.network_firewall_us.endpoint_id_az
  bucket_logs_arn = data.aws_s3_bucket.bucket_centralized_logs.arn
}

module "dns_us" {
  source = "./modules/dns"
  cidr_block       = data.aws_ssm_parameter.cidr_block_us.value
  cidr_block_sum        = data.aws_ssm_parameter.cidr_block_sum_us.value
  project                     = data.aws_ssm_parameter.project.value
  environment                 = data.aws_ssm_parameter.environment.value
  vpc_dns_id                  = module.vpc_us.vpc_dns_id
  subnet_dns_list             = module.vpc_us.vpc_dns_subnets
}

module "vpc_endpoints_us" {
  source = "./modules/vpcEndpoints"
  cidr_block               = data.aws_ssm_parameter.cidr_block_us.value
  cidr_block_sum        = data.aws_ssm_parameter.cidr_block_sum_us.value
  project                     = data.aws_ssm_parameter.project.value
  environment                 = data.aws_ssm_parameter.environment.value
  vpc_shared_id                  = module.vpc_us.vpc_shared_id
  subnet_shared_list             = module.vpc_us.vpc_shared_subnets
  endpoints = {
        git-codecommit = {
          service = "git-codecommit"
          service_type = "Interface"
        }
        codecommit = {
          service = "codecommit"
          service_type = "Interface"
        }
        s3 = {
          service = "s3"
          service_type = "Interface"
        }
        dynamodb = {
          service = "dynamodb"
          service_type = "Gateway"
        }
      }
}

module "network_firewall_us" {
    source  = "./modules/network_firewall/"
    firewall_name = "fw-01"
    vpc_id        = module.vpc_us.vpc_outbound_id
    environment        = data.aws_ssm_parameter.environment.value
    subnet_mapping = [
        module.vpc_us.vpc_outbound_fw_subnets[0],
        module.vpc_us.vpc_outbound_fw_subnets[1]
    ]
    bucket_logs_name = data.aws_s3_bucket.bucket_centralized_logs.bucket
}
