# ── DEV (Learner Lab) ───────────────────────────────────
# Il bucket viene creato via CLI (setup-dev.sh) perché il Learner Lab
# blocca s3:GetBucketObjectLockConfiguration via SCP.

data "aws_s3_bucket" "site" {
  count  = var.use_oac ? 0 : 1
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "site_dev" {
  count  = var.use_oac ? 0 : 1
  bucket = data.aws_s3_bucket.site[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${data.aws_s3_bucket.site[0].arn}/*"
    }]
  })
}

# ── PROD (AWS reale) ─────────────────────────────────────

resource "aws_s3_bucket" "site" {
  count         = var.use_oac ? 1 : 0
  bucket        = var.bucket_name
  force_destroy = true
  tags          = { Environment = var.environment }
}

resource "aws_s3_bucket_versioning" "site" {
  count  = var.use_oac ? 1 : 0
  bucket = aws_s3_bucket.site[0].id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  count  = var.use_oac ? 1 : 0
  bucket = aws_s3_bucket.site[0].id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  count                   = var.use_oac ? 1 : 0
  bucket                  = aws_s3_bucket.site[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "site_prod" {
  count      = var.use_oac ? 1 : 0
  depends_on = [aws_s3_bucket_public_access_block.site]
  bucket     = aws_s3_bucket.site[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontOAC"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.site[0].arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = var.cloudfront_distribution_arn
        }
      }
    }]
  })
}
