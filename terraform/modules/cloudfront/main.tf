resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = var.price_class
  web_acl_id          = var.waf_acl_arn

  origin {
    domain_name              = var.bucket_regional_domain
    origin_id                = "S3-OAC"
    origin_access_control_id = var.oac_id
  }

  default_cache_behavior {
    target_origin_id       = "S3-OAC"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = { Environment = var.environment }
}
