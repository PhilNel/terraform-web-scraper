terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "artefact" {
  bucket        = var.bucket_name
  force_destroy = true
}

# Customer-managed KMS not required for this artifact bucket since it only contains binaries.
# tfsec:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "artefact_encryption" {
  bucket = aws_s3_bucket.artefact.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artefact_block" {
  bucket = aws_s3_bucket.artefact.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artefacts" {
  bucket = aws_s3_bucket.artefact.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_ecr_repository" "parser_lambda" {
  name = "perl-parser-lambda"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}