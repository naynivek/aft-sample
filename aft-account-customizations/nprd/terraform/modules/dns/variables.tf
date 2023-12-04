variable "vpc_id" {
  type = string
}

variable "resolver_rules" {
  description = "List of all resolver_rules in use by network rule"
  type        = list(string)
  default = ["none"]
}

