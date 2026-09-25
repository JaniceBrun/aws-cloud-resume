output "bucket_id" {
  value = var.use_oac ? aws_s3_bucket.site[0].id : data.aws_s3_bucket.site[0].id
}
output "bucket_arn" {
  value = var.use_oac ? aws_s3_bucket.site[0].arn : data.aws_s3_bucket.site[0].arn
}
output "bucket_regional_domain" {
  value = var.use_oac ? aws_s3_bucket.site[0].bucket_regional_domain_name : data.aws_s3_bucket.site[0].bucket_regional_domain_name
}
output "website_endpoint" {
  value = var.use_oac ? "" : data.aws_s3_bucket.site[0].website_endpoint
}
