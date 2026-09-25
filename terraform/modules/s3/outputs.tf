output "bucket_id"              { value = data.aws_s3_bucket.site.id }
output "bucket_arn"             { value = data.aws_s3_bucket.site.arn }
output "bucket_regional_domain" { value = data.aws_s3_bucket.site.bucket_regional_domain_name }
output "website_endpoint"       { value = data.aws_s3_bucket.site.website_endpoint }
