output "cloudfront_url" {
  description = "URL pubblico del sito via CloudFront (solo se enable_cloudfront = true)"
  value       = var.enable_cloudfront ? "https://${module.cloudfront[0].cloudfront_domain}" : "CloudFront non abilitato — usa s3_website_url"
}

output "s3_website_url" {
  description = "URL diretto S3 (dev senza CloudFront)"
  value       = "http://${module.s3.website_endpoint}"
}

output "api_gateway_url" {
  description = "Endpoint API Gateway per il contatore visite"
  value       = module.api_gateway.api_url
}

output "cloudfront_distribution_id" {
  description = "ID distribuzione CloudFront (solo se enable_cloudfront = true)"
  value       = var.enable_cloudfront ? module.cloudfront[0].distribution_id : "N/A"
}

output "bucket_name" {
  description = "Nome del bucket S3"
  value       = module.s3.bucket_id
}
