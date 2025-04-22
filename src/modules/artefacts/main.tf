provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "artefact" {
  bucket        = var.bucket_name
  force_destroy = true
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
