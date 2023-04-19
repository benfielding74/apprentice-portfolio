resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "A" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain}"
  type    = "A"
}

resource "aws_route53_record" "AAAA" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain}"
  type    = "AAAA"
}