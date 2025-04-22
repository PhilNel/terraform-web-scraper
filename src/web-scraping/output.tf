output "fetcher_output_bucket_name" {
  description = "Name of the S3 bucket used for fetcher output"
  value       = aws_s3_bucket.fetcher_output.bucket
}