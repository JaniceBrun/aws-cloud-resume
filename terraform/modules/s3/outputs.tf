output "bucket_id"             { value = aws_s3_bucket.site.id }
output "bucket_arn"            { value = aws_s3_bucket.site.arn }
output "website_endpoint"      { value = aws_s3_bucket_website_configuration.site.website_endpoint }
output "bucket_regional_domain" { value = aws_s3_bucket.site.bucket_regional_domain_name }
