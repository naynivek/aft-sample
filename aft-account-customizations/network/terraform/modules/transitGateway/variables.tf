variable "amazon_side_asn" {
  description = "Amazon ASN value"
  type    = string
}

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

variable "outbound_tgvpc_id" {
  description = "Oubound VPC Attachment ID"
  type        = string
}

variable "inbound_tgvpc_id" {
  description = "Inbound VPC Attachment ID"
  type        = string
}

variable "shared_tgvpc_id" {
  description = "Shared VPC Attachment ID"
  type        = string
}

variable "dns_tgvpc_id" {
  description = "DNS VPC Attachment ID"
  type        = string
}