data "aws_ecr_repository" "parser_lambda" {
  name = "parser-lambda"
}

resource "aws_lambda_function" "parser_lambda" {
  function_name = "parser-lambda"
  package_type  = "Image"
  role          = aws_iam_role.parser_lambda_exec.arn
  memory_size   = var.parser_memory_size
  timeout       = var.parser_timeout_in_seconds
  publish       = true

  image_uri = "${data.aws_ecr_repository.parser_lambda.repository_url}:${var.parser_version}"

  environment {
    variables = {
      PROVIDER_S3_BUCKET_NAME = aws_s3_bucket.fetcher_output.bucket
      PROVIDER_S3_BUCKET_KEY  = "rendered.html"
      SCRAPER_PROVIDER_TYPE   = "s3",
      STORE_DYNAMO_TABLE_NAME = aws_dynamodb_table.job_store.id,
      SCRAPER_SINK_TYPE       = "dynamo",
    }
  }
}

resource "aws_lambda_alias" "parser_latest" {
  name             = "latest"
  function_name    = aws_lambda_function.parser_lambda.function_name
  function_version = aws_lambda_function.parser_lambda.version
}

resource "aws_iam_role" "parser_lambda_exec" {
  name = "parser_lambda_exec_role"

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
  name   = "parser_lambda_s3_policy"
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
  name   = "parser_lambda_dynamo_policy"
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
