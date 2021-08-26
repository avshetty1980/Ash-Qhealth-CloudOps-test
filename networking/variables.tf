# ---- networking/variables.tf  ----

variable "vpc_cidr" {
  type = string
}

variable "public_cidrs" {
  type = list(any)
}

# variable "private_cidrs" {
#   type = list(any)
# }

variable "public_snet_count" {
  type = number
}

# variable "private_snet_count" {
#   type = number
# }

variable "access_ip" {
  type = string
}

variable "security_groups" {}

variable "max_subnets" {}
