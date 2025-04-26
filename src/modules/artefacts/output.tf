output "bucket_name" {
  value = aws_s3_bucket.artefact.bucket
}

output "parser_lambda_ecr_repo_url" {
  value = aws_ecr_repository.parser_lambda.repository_url
}