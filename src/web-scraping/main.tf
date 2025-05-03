terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }
  }
}

resource "aws_s3_bucket" "fetcher_output" {
  bucket = "web-scraper-output-${var.environment}-${var.aws_region}"

  tags = {
    Name        = "web-scraper-output-dev"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "fetcher_output" {
  bucket = aws_s3_bucket.fetcher_output.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Customer-managed KMS not required for this bucket since it's publically accessible HTML.
# tfsec:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "fetcher_output" {
  bucket = aws_s3_bucket.fetcher_output.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "job_store" {
  name         = "web-scraper-jobs-${var.environment}-${var.aws_region}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "job_id"

  attribute {
    name = "job_id"
    type = "S"
  }
}

