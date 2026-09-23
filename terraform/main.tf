terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Alias obbligatorio per WAF CloudFront (deve essere us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Regione e account attivi ricavati dall'account autenticato (equivale a sts get-caller-identity)
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# WAF in us-east-1, ARN passato al modulo cloudfront
resource "aws_wafv2_web_acl" "cdn" {
  provider    = aws.us_east_1
  name        = "cloud-resume-waf-${var.environment}"
  scope       = "CLOUDFRONT"
  description = "WAF per CloudFront cloud-resume"

  default_action { allow {} }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 2
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IpReputationList"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloud-resume-waf"
    sampled_requests_enabled   = true
  }

  tags = { Environment = var.environment }
}

# OAC creato nel root per rompere la dipendenza circolare S3 ↔ CloudFront.
# L'ARN della distribuzione è costruito deterministicamente dall'account ID
# e passato a S3 prima che CloudFront esista.
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${var.environment}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  # ARN CloudFront costruito deterministicamente — non dipende dalla distribuzione
  cloudfront_distribution_arn = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${module.cloudfront.distribution_id}"
}

# ── Moduli ──────────────────────────────────────────────

module "s3" {
  source                      = "./modules/s3"
  bucket_name                 = var.bucket_name
  environment                 = var.environment
  cloudfront_distribution_arn = local.cloudfront_distribution_arn
}

module "cloudfront" {
  source                 = "./modules/cloudfront"
  bucket_regional_domain = module.s3.bucket_regional_domain
  oac_id                 = aws_cloudfront_origin_access_control.oac.id
  environment            = var.environment
  price_class            = var.cloudfront_price_class
  waf_acl_arn            = aws_wafv2_web_acl.cdn.arn
}

module "dynamodb" {
  source      = "./modules/dynamodb"
  table_name  = var.dynamodb_table_name
  environment = var.environment
}

module "lambda" {
  source               = "./modules/lambda"
  function_name        = var.lambda_function_name
  table_name           = module.dynamodb.table_name
  table_arn            = module.dynamodb.table_arn
  lab_role_arn         = var.lab_role_arn
  environment          = var.environment
}

module "api_gateway" {
  source            = "./modules/api_gateway"
  api_name          = var.api_name
  lambda_invoke_arn = module.lambda.invoke_arn
  lambda_arn        = module.lambda.function_arn
  lambda_name       = module.lambda.function_name
  environment       = var.environment
  aws_region        = data.aws_region.current.name
}

# ── Upload file frontend su S3 ───────────────────────────

resource "aws_s3_object" "html" {
  bucket       = module.s3.bucket_id
  key          = "index.html"
  source       = "${path.root}/../frontend/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.root}/../frontend/index.html")
}

resource "aws_s3_object" "css" {
  bucket       = module.s3.bucket_id
  key          = "styles.css"
  source       = "${path.root}/../frontend/styles.css"
  content_type = "text/css"
  etag         = filemd5("${path.root}/../frontend/styles.css")
}

resource "aws_s3_object" "js" {
  bucket       = module.s3.bucket_id
  key          = "script.js"
  source       = "${path.root}/../frontend/script.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.root}/../frontend/script.js")
}
