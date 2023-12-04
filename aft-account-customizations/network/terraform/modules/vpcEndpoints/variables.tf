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

variable "vpc_shared_id" {
  description = "VPC SHARED ID"
  type        = string
}

variable "subnet_shared_list" {
  description = "SHARED Subnets CIDR"
  type        = any
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting VPC endpoint resources"
  type        = map(string)
  default     = {}
}

variable "endpoints" {
  description = "VPC Endpoints to create"
  type        = any
  default     = {}
}