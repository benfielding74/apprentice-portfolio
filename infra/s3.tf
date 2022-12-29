# create an s3 bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket        = "www.${var.domain}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id
  acl    = "public-read"
}

data "aws_iam_policy_document" "policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.web_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = <<POLICY
{

  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::www.${var.domain}/*"
      ]
    }
  ]
}
  POLICY
}

resource "aws_s3_bucket_website_configuration" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_object" "object" {
  for_each = fileset("/home/thelazydiarist/Code/apprentice-portfolio/public/", "**")
  bucket   = aws_s3_bucket.web_bucket.id
  key      = each.value
  source   = "/home/thelazydiarist/Code/apprentice-portfolio/public/${each.value}"
  acl      = "public-read"
}

