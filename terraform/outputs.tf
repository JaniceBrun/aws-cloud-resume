output "cloudfront_url" {
  description = "URL pubblico del sito via CloudFront"
  value       = "https://${module.cloudfront.cloudfront_domain}"
}

output "api_gateway_url" {
  description = "Endpoint API Gateway per il contatore visite"
  value       = module.api_gateway.api_url
}

output "cloudfront_distribution_id" {
  description = "ID distribuzione CloudFront"
  value       = module.cloudfront.distribution_id
}

output "bucket_name" {
  description = "Nome del bucket S3"
  value       = module.s3.bucket_id
}
