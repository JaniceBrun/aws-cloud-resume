# aws-cloud-resume
Cloud Resume Challenge — Resume statico hostato su AWS con contatore visite serverless e deploy via Terraform.

---

## Architettura

```
Browser → CloudFront (CDN + WAF) → S3 (HTML/CSS/JS)
                                 → API Gateway → Lambda → DynamoDB
```

### Moduli

| Modulo | Contenuto |
|---|---|
| `modules/s3` | Bucket con hosting statico, versioning, AES-256, public access solo GetObject |
| `modules/cloudfront` | CDN HTTPS, cache TTL, WAF con `AWSManagedRulesCommonRuleSet` e `AWSManagedRulesAmazonIpReputationList` |
| `modules/dynamodb` | Tabella `id (S)`, PAY_PER_REQUEST, encryption at-rest, item unico con `visit_count` |
| `modules/lambda` | Python 3.12, `UpdateItem ADD` atomico su DynamoDB, LabRole, zip via `archive_file` |
| `modules/api_gateway` | REST API `GET /count`, integrazione proxy Lambda, permesso invocazione per ARN |

---

## Deploy

```bash
# 1. Compila le variabili
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# → sostituisci <ACCOUNT_ID> con il tuo (AWS Details → IAM Role ARN)

# 2. Deploy
cd terraform
terraform init
terraform apply
```

Gli output restituiscono `cloudfront_url` e `api_gateway_url` da usare in `frontend/script.js`.
