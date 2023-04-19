data "aws_acm_certificate" "cert" {
  domain      = var.domain
  statuses    = ["AMAZON_ISSUED"]
  most_recent = true
}

data "http" "aws_ip_ranges" {
  url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
}
