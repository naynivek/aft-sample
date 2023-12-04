module "phz_workloads" {
  source                              = "./modules/dns/route53_phz"
  vpc_dns_id_us = module.vpc_us.vpc_dns_id
  vpc_dns_id_sa = module.vpc_sa.vpc_dns_id
  providers = {
    aws.sa = aws.sa
  }
}