# Il bucket viene creato via CLI (setup-dev.sh) perché il Learner Lab
# blocca s3:GetBucketObjectLockConfiguration via SCP su qualsiasi
# operazione Terraform sul bucket S3.
# Terraform legge il bucket esistente tramite data source.

data "aws_s3_bucket" "site" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "site" {
  bucket = data.aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${data.aws_s3_bucket.site.arn}/*"
    }]
  })
}
