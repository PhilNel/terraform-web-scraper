resource "aws_lambda_function" "fetcher_lambda" {
  function_name = "fetcher_lambda"
  role          = aws_iam_role.fetcher_lambda_exec.arn
  handler       = "src/index.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.artefact_bucket
  s3_key    = "fetcher_lambda.zip"

  environment {
    variables = {
      WRITER_S3_BUCKET_NAME = aws_s3_bucket.fetcher_output.bucket
      WRITER_TYPE           = "s3"
      NODE_ENV              = "production"
    }
  }
}

resource "aws_iam_role" "fetcher_lambda_exec" {
  name = "fetcher_lambda_exec_role"

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


data "aws_iam_policy_document" "fetcher_lambda_s3_access" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.fetcher_output.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "fetcher_lambda_s3" {
  name   = "fetcher_lambda_s3_policy"
  policy = data.aws_iam_policy_document.fetcher_lambda_s3_access.json
}

resource "aws_iam_role_policy_attachment" "fetcher_lambda_s3_attach" {
  role       = aws_iam_role.fetcher_lambda_exec.name
  policy_arn = aws_iam_policy.fetcher_lambda_s3.arn
}

resource "aws_iam_role_policy_attachment" "fetcher_lambda_logs" {
  role       = aws_iam_role.fetcher_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
