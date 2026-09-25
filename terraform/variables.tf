variable "aws_region" {
  type        = string
  description = "AWS region principale"
}

variable "environment" {
  type        = string
  description = "Nome ambiente (es. dev, prod)"
}

variable "bucket_name" {
  type        = string
  description = "Nome univoco del bucket S3 per il sito"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Nome della tabella DynamoDB per il contatore"
}

variable "lambda_function_name" {
  type        = string
  description = "Nome della Lambda function"
}

variable "api_name" {
  type        = string
  description = "Nome dell'API Gateway"
}

# lab_role_arn non è una variabile — viene costruito dinamicamente
# in main.tf usando data.aws_caller_identity.current.account_id

variable "cloudfront_price_class" {
  type        = string
  description = "Price class CloudFront (PriceClass_100 | PriceClass_200 | PriceClass_All)"
  default     = "PriceClass_100"
}

variable "enable_cloudfront" {
  type        = bool
  description = "Abilita CloudFront e WAF (false per dev su Learner Lab)"
  default     = true
}

variable "use_oac" {
  type        = bool
  description = "Usa OAC per S3 (true per prod, false per dev/Learner Lab)"
  default     = true
}
