output "fetcher_output_bucket_name" {
  description = "Name of the S3 bucket used for fetcher output"
  value       = aws_s3_bucket.fetcher_output.bucket
}

output "job_table_name" {
  description = "Name of the Dynamo DB table where parsed jobs are stored"
  value       = aws_dynamodb_table.job_store.name
}