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
  description = "Project CIDR block"
  type        = string
}

variable "cidr_block_sum" {
  description = "Summarized block CIDR"
  type        = string
}

variable "outside_cidr_block_sum" {
  description = "Outside Summarized block CIDR"
  type        = string
}

variable "tg_id" {
  description = "Transit Gateway ID"
  type        = string
}

variable "rtb_shrd_id" {
  description = "Transit Gateway Shared Route Table ID"
  type        = string
}

variable "rtb_out_id" {
  description = "Transit Gateway Outbound Route Table ID"
  type        = string
}

variable "rtb_in_id" {
  description = "Transit Gateway Inbound Route Table ID"
  type        = string
}

variable "rtb_prd_id" {
  description = "Transit Gateway PRD Route Table ID"
  type        = string
}

variable "rtb_nprd_id" {
  description = "Transit Gateway NPRD Route Table ID"
  type        = string
}

variable "net_fw_id_azs" {
  description = "Network Firewall ID per AZ"
  type        = any
}

variable "bucket_logs_arn" {
  description = "Centralized Bucket Logs ARN"
  type        = string
  default = "none"
}
