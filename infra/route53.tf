resource "aws_route53_zone" "main" {
  name = var.domain
}

output "main_zone_nameservers" {
  value = aws_route53_zone.main.name_servers
}

resource "aws_route53_record" "AAAA" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain}"
  type    = "AAAA"
  alias {
    name                   = aws_lb.portfolio.dns_name
    zone_id                = aws_lb.portfolio.zone_id
    evaluate_target_health = false
  }
}
