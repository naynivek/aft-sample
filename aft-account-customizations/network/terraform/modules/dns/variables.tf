variable "project" {
  description = "Project Identifier"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Project Environmnet"
  type        = string
}

variable "cidr_block" {
  description = "simple CIDR block"
  type        = string
}

variable "cidr_block_sum" {
  description = "Summarized block CIDR"
  type        = string
}

variable "vpc_dns_id" {
  description = "VPC DNS ID"
  type        = string
}

variable "subnet_dns_list" {
  description = "List of DNS Subnets"
  type        = any
}

variable "cisco_umbrella_ips" {
  description = "Umbrella Public IPs"
  type = list(string)
  default = ["208.67.220.220","208.67.222.222"]
}