# get the ip address range for route 53 in eu-west-2
locals {
  route53_ip_range = jsondecode(data.http.aws_ip_ranges.body).prefixes[22].ip_prefix
}