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
| `modules/s3` | Bucket con hosting statico, versioning, AES-256, public access block, bucket policy OAC |
| `modules/cloudfront` | CDN HTTPS, OAC, cache TTL, WAF con `AWSManagedRulesCommonRuleSet` e `AWSManagedRulesAmazonIpReputationList` |
| `modules/dynamodb` | Tabella `id (S)`, PAY_PER_REQUEST, encryption at-rest, item unico con `visit_count` |
| `modules/lambda` | Python 3.12, `UpdateItem ADD` atomico su DynamoDB, LabRole (IAM role reale commentato per prod) |
| `modules/api_gateway` | REST API `GET /count`, integrazione proxy Lambda, permesso invocazione per ARN |

---

## Deploy

### DEV — locale su AWS Learner Lab

Le credenziali del Learner Lab scadono ad ogni sessione e vanno esportate nel terminale prima di eseguire Terraform.

```bash
# 1. Esporta le credenziali da Learner Lab → AWS Details
export AWS_ACCESS_KEY_ID="<aws_access_key_id>"
export AWS_SECRET_ACCESS_KEY="<aws_secret_access_key>"
export AWS_SESSION_TOKEN="<aws_session_token>"

# 2. Bootstrap — solo la prima volta (crea tabella DynamoDB per il lock di prod)
cd terraform/bootstrap
terraform init
terraform apply -var="aws_region=us-east-1" -var="environment=dev"

# 3. Inizializza Terraform con stato locale (Learner Lab non supporta remote state)
cd ..

# 4. Verifica il piano
terraform plan

# 5. Deploy
terraform apply
```

Gli output restituiscono `cloudfront_url`, `api_gateway_url` e `bucket_name`.

### PROD — automatico via GitHub Actions

Il bootstrap va eseguito una volta sola sull'account AWS reale prima del primo deploy.

```bash
# 1. Configura le credenziali AWS reali nel terminale
export AWS_ACCESS_KEY_ID="<aws_access_key_id>"
export AWS_SECRET_ACCESS_KEY="<aws_secret_access_key>"

# 2. Bootstrap — una volta sola
cd terraform/bootstrap
terraform init
terraform apply -var="aws_region=us-east-1" -var="environment=prod"
```

Dopo il bootstrap il deploy parte automaticamente ad ogni push sul branch `main`.

```bash
git checkout main
git merge dev
git push origin main
```

I secrets AWS reali (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) vanno configurati in GitHub → Settings → Environments → `prod`.
