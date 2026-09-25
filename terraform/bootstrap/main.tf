terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_dynamodb_table" "tflock" {
  name         = "cloud-resume-tflock-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = { Environment = var.environment }
}

output "state_bucket" {
  value = "cloud-resume-tfstate-${var.environment}-${data.aws_caller_identity.current.account_id}"
}
output "lock_table" { value = aws_dynamodb_table.tflock.name }
