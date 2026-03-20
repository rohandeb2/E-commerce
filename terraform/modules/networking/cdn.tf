# 1. CloudFront Distribution (The Global Edge)
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-${var.project_name}-assets"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.project_name}-assets"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = { Name = "${var.project_name}-cdn" }
}

# 2. Origin Access Identity (Security: Makes S3 accessible ONLY via CloudFront)
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.project_name} S3 assets"
}

# 3. Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name
}