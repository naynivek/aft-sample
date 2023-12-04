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
  description = "VPC CIDR BLOCK"
  type        = string
}

variable "bucket_logs_arn" {
  description = "Centralized Bucket Logs ARN"
  type        = string
  default = "none"
}

variable "vpc_endpoints" {
  description = "List of all vpc_endpoints in use"
  type        = list(string)
  default = ["none"]
}
