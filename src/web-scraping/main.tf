resource "aws_s3_bucket" "fetcher_output" {
  bucket = "web-scraper-output-${var.environment}-${var.aws_region}"

  tags = {
    Name        = "web-scraper-output-dev"
    Environment = var.environment
  }
}
