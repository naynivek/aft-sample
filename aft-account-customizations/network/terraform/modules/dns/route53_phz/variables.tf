variable "vpc_dns_id_us" {
  type     = string
  description = "US DNS VPC ID that will be associated with this hosted zone"
}

variable "vpc_dns_id_sa" {
  type     = string
  description = "SA DNS VPC ID that will be associated with this hosted zone"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Whether to destroy all records inside if the hosted zone is deleted"
}

variable "tags" {
  type    = map(string)
  default = {}
}