module "tg_sa" {
  providers = {
    aws = aws.sa
  }
  amazon_side_asn       = "64514"
  source                = "./modules/transitGateway"
  project               = data.aws_ssm_parameter.project.value
  environment           = data.aws_ssm_parameter.environment.value
  outbound_tgvpc_id     = module.vpc_sa.aws_ec2_transit_gateway_vpc_att_outbound
  inbound_tgvpc_id      = module.vpc_sa.aws_ec2_transit_gateway_vpc_att_inbound
  shared_tgvpc_id       = module.vpc_sa.aws_ec2_transit_gateway_vpc_att_shared
  dns_tgvpc_id          = module.vpc_sa.aws_ec2_transit_gateway_vpc_att_dns
  cidr_block         = data.aws_ssm_parameter.cidr_block_sa.value
}

module "vpc_sa" {
  providers = {
    aws = aws.sa
  }
  source = "./modules/vpc"
  cidr_block      = data.aws_ssm_parameter.cidr_block_sa.value
  cidr_block_sum        = data.aws_ssm_parameter.cidr_block_sum_sa.value
  outside_cidr_block_sum        = data.aws_ssm_parameter.cidr_block_sum_us.value
  project                   = data.aws_ssm_parameter.project.value
  environment               = data.aws_ssm_parameter.environment.value
  tg_id                  = module.tg_sa.transit_gateway_id
  rtb_shrd_id            = module.tg_sa.route_table_shared
  rtb_out_id             = module.tg_sa.route_table_outbound
  rtb_in_id              = module.tg_sa.route_table_inbound
  rtb_nprd_id             = module.tg_sa.route_table_nprd
  rtb_prd_id             = module.tg_sa.route_table_prd
  net_fw_id_azs              = module.network_firewall_sa.endpoint_id_az
  bucket_logs_arn = data.aws_s3_bucket.bucket_centralized_logs.arn
}

module "dns_sa" {
  providers = {
    aws = aws.sa
  }
  source = "./modules/dns"
  cidr_block        = data.aws_ssm_parameter.cidr_block_sa.value
  cidr_block_sum        = data.aws_ssm_parameter.cidr_block_sum_sa.value
  project                     = data.aws_ssm_parameter.project.value
  environment                 = data.aws_ssm_parameter.environment.value
  vpc_dns_id                  = module.vpc_sa.vpc_dns_id
  subnet_dns_list             = module.vpc_sa.vpc_dns_subnets
}

module "vpc_endpoints_sa" {
  providers = {
    aws = aws.sa
  }
  source = "./modules/vpcEndpoints"
  cidr_block                = data.aws_ssm_parameter.cidr_block_sa.value
  cidr_block_sum        = data.aws_ssm_parameter.cidr_block_sum_sa.value
  project                     = data.aws_ssm_parameter.project.value
  environment                 = data.aws_ssm_parameter.environment.value
  vpc_shared_id                  = module.vpc_sa.vpc_shared_id
  subnet_shared_list             = module.vpc_sa.vpc_shared_subnets
  endpoints = {
        s3 = {
          service = "s3"
          service_type = "Interface" #https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html#associate-route-tables-s3
        }
        dynamodb = {
          service = "dynamodb"
          service_type = "Gateway"
        }
      }
}

module "network_firewall_sa" {
    providers = {
    aws = aws.sa
    }
    source  = "./modules/network_firewall/"
    firewall_name = "fw-01"
    vpc_id        = module.vpc_sa.vpc_outbound_id
    environment        = data.aws_ssm_parameter.environment.value
    subnet_mapping = [
        module.vpc_sa.vpc_outbound_fw_subnets[0],
        module.vpc_sa.vpc_outbound_fw_subnets[1]
    ]
    bucket_logs_name = data.aws_s3_bucket.bucket_centralized_logs.bucket
}

