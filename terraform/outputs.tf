output "cloudfront_url" {
  description = "URL pubblico del sito via CloudFront"
  value       = "https://${module.cloudfront.cloudfront_domain}"
}

output "api_gateway_url" {
  description = "Endpoint API Gateway per il contatore visite"
  value       = module.api_gateway.api_url
}

output "s3_website_url" {
  description = "URL diretto S3 (non usare in produzione, usa CloudFront)"
  value       = "http://${module.s3.website_endpoint}"
}

output "cloudfront_distribution_id" {
  description = "ID distribuzione CloudFront (utile per invalidare la cache)"
  value       = module.cloudfront.distribution_id
}
