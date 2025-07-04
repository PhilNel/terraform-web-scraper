locals {
  parser_env_vars = {
    PROVIDER_S3_BUCKET_NAME = aws_s3_bucket.fetcher_output.bucket
    PROVIDER_S3_BUCKET_KEY  = "rendered.html"
    SCRAPER_PROVIDER_TYPE   = "s3"
    STORE_DYNAMO_TABLE_NAME = aws_dynamodb_table.job_store.id
    SCRAPER_SINK_TYPE       = "dynamo"
  }
}

data "aws_s3_object" "parser_lambda" {
  bucket = var.artefact_bucket
  key    = "go-parser-lambda.zip"
}

data "aws_ecr_repository" "parser_lambda" {
  name = "perl-parser-lambda"
}

resource "aws_lambda_function" "perl_parser_lambda" {
  function_name = "${local.prefix}perl-parser-lambda"
  package_type  = "Image"
  role          = aws_iam_role.parser_lambda_exec.arn
  memory_size   = var.parser_memory_size
  timeout       = var.parser_timeout_in_seconds
  publish       = true

  image_uri = "${data.aws_ecr_repository.parser_lambda.repository_url}:${var.parser_version}"

  environment {
    variables = local.parser_env_vars
  }
}

resource "aws_lambda_alias" "perl_parser_latest" {
  name             = "latest"
  function_name    = aws_lambda_function.perl_parser_lambda.function_name
  function_version = aws_lambda_function.perl_parser_lambda.version
}

resource "aws_lambda_function" "go_parser_lambda" {
  function_name = "${local.prefix}go-parser-lambda"
  role          = aws_iam_role.parser_lambda_exec.arn
  handler       = "handler"
  runtime       = "provided.al2"
  memory_size   = var.parser_memory_size
  timeout       = var.parser_timeout_in_seconds
  publish       = true

  s3_bucket         = data.aws_s3_object.parser_lambda.bucket
  s3_key            = data.aws_s3_object.parser_lambda.key
  s3_object_version = data.aws_s3_object.parser_lambda.version_id
  environment {
    variables = local.parser_env_vars
  }
}

resource "aws_lambda_alias" "go_parser_latest" {
  name             = "latest"
  function_name    = aws_lambda_function.go_parser_lambda.function_name
  function_version = aws_lambda_function.go_parser_lambda.version
}

resource "aws_iam_role" "parser_lambda_exec" {
  name = "${local.prefix}parser-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


data "aws_iam_policy_document" "parser_lambda_s3_access" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.fetcher_output.bucket}"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.fetcher_output.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "parser_lambda_s3" {
  name   = "${local.prefix}parser-lambda-s3-policy"
  policy = data.aws_iam_policy_document.parser_lambda_s3_access.json
}

resource "aws_iam_role_policy_attachment" "parser_lambda_s3_attach" {
  role       = aws_iam_role.parser_lambda_exec.name
  policy_arn = aws_iam_policy.parser_lambda_s3.arn
}

data "aws_iam_policy_document" "parser_lambda_dynamo_access" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]

    resources = [
      aws_dynamodb_table.job_store.arn
    ]
  }
}

resource "aws_iam_policy" "parser_lambda_dynamo" {
  name   = "${local.prefix}parser-lambda-dynamo-policy"
  policy = data.aws_iam_policy_document.parser_lambda_dynamo_access.json
}

resource "aws_iam_role_policy_attachment" "parser_lambda_dynamo_attach" {
  role       = aws_iam_role.parser_lambda_exec.name
  policy_arn = aws_iam_policy.parser_lambda_dynamo.arn
}

resource "aws_iam_role_policy_attachment" "parser_lambda_logs" {
  role       = aws_iam_role.parser_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
