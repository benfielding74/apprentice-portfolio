variable "profile" {
  type        = string
  description = "AWS tutorial account"
  default     = "vscode"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "domain" {
  type        = string
  description = "Apex domain name"
  default     = "bfieldingapprenticeportfolio.me"
}

variable "availability_zones" {
  type    = list(string)
  description = "Subnet availability zones"
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}
