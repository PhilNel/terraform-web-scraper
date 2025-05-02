terraform {
  required_version = ">= 1.11.0"

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
