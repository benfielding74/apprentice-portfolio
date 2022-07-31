data "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "A" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = var.domain
  type = "A"

  alias {
    name                    = aws_cloudfront_distribution.distribution.domain_name
    zone_id                 = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health  = false
  }
}