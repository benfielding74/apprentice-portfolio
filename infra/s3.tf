# create an s3 bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket = var.domain
  force_destroy = true

}

resource "aws_S3_acl" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id
  acl    = "public"
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
        "arn:aws:s3:::${var.domain}/*"
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
    suffix = "404.html"
  }
}

