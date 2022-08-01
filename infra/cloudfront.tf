resource "aws_cloudfront_distribution" "distribution" {
  provider = aws.us_east_1

  origin {
    domain_name = aws_s3_bucket.web_bucket.website_endpoint
    origin_id   = aws_s3_bucket.web_bucket.website_endpoint
  

    custom_origin_config {
      http_port               = 80
      https_port              = 443
      origin_protocol_policy  = "http-only"
      origin_ssl_protocols    = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = ""
  default_root_object = "index.html"

  aliases   = ["www.${var.domain}"]

  default_cache_behaviour {
    allowed_methods    = ["GET", "HEAD"]
    cached_methods     = ["GET", "HEAD"]
    target_origin_id   = aws_s3_bucket.web_bucket.website_endpoint
    compress           = true
  

    forwarded_values {
      query_string  = false
      headers       = ["ORIGIN"]

      cookies {
        forward = "none"
      }
    }
  

    viewer_protocol_policy  = "redirect-to-https"
    min_ttl                 = 0
    default_ttl             = 86400
    compress                = true
    max_ttl                 = 31536000
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  restrictions {
    geo_restriction {
      restriction_type  = "none"
    }
  }
}

