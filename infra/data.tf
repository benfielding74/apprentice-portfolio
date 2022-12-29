data "aws_acm_certificate" "cert" {
  provider    = aws.east
  domain      = var.domain
  statuses    = ["ISSUED"]
  most_recent = true
}