#!/bin/bash
# Esegui questo script UNA VOLTA prima di terraform apply su dev
# Crea e configura il bucket S3 via CLI (il Learner Lab blocca Terraform su S3)

BUCKET="cloud-resume-janice-brun-dev"
REGION="us-east-1"

echo "Creazione bucket $BUCKET..."
aws s3api create-bucket --bucket $BUCKET --region $REGION

echo "Versioning..."
aws s3api put-bucket-versioning \
  --bucket $BUCKET \
  --versioning-configuration Status=Enabled

echo "Encryption..."
aws s3api put-bucket-encryption \
  --bucket $BUCKET \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "Public access block off..."
aws s3api put-public-access-block \
  --bucket $BUCKET \
  --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

echo "Website hosting..."
aws s3api put-bucket-website \
  --bucket $BUCKET \
  --website-configuration '{"IndexDocument":{"Suffix":"index.html"},"ErrorDocument":{"Key":"index.html"}}'

echo "Bucket $BUCKET pronto."
