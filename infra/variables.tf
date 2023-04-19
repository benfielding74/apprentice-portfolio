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
