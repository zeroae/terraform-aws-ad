variable "domain_name" {
  description = "The base domain name for the Directory Service. AD will be preprended to this name by default."
}

variable "password" {
  description = "The password for the AD administrator"
}

variable "vpc_id" {
  description = "The VPC for AD"
}

variable "availability_zones" {
  description = "The two availability zones to use for AD."
  type = "list"
}

variable "cidr_blocks" {
  description = "The two CIDR blocks for the AD subnet. Suggest two dedicated /28."
  type = "list"
}
