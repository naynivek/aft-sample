data "aws_caller_identity" "current" {}

data "aws_region" "sa" {
  provider = aws.sa
}

data "aws_ssm_parameter" "cidr_block_sum_sa" {
  name = "/aft/account-request/custom-fields/cidr_block_summarized_sa"
}

data "aws_ssm_parameter" "cidr_block_sum_us" {
  name = "/aft/account-request/custom-fields/cidr_block_summarized_us"
}

data "aws_ssm_parameter" "cidr_block_us" {
  name = "/aft/account-request/custom-fields/cidr_block_us"
}

data "aws_ssm_parameter" "cidr_block_sa" {
  name = "/aft/account-request/custom-fields/cidr_block_sa"
}

data "aws_ssm_parameter" "environment" {
  name = "/aft/account-request/custom-fields/environment"
}

data "aws_ssm_parameter" "project" {
  name = "/aft/account-request/custom-fields/project"
}

data "aws_s3_bucket" "bucket_centralized_logs" {
  provider = aws.log
  bucket = "vpc-flow-logs-centralized-default"
}
