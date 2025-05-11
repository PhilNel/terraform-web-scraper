resource "aws_cloudwatch_event_target" "fetcher_target" {
  rule      = aws_cloudwatch_event_rule.fetcher_schedule.name
  target_id = "${local.prefix}fetcher-lambda"
  arn       = aws_lambda_function.fetcher_lambda.arn
}


resource "aws_cloudwatch_event_rule" "fetcher_schedule" {
  name                = "${local.prefix}fetcher-lambda-schedule"
  description         = "Run fetcher lambda"
  schedule_expression = var.fetcher_schedule_expression
  state               = "ENABLED"
}

resource "aws_lambda_permission" "fetcher_allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetcher_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fetcher_schedule.arn
}

resource "aws_cloudwatch_event_rule" "parser_trigger" {
  name        = "${local.prefix}s3-parser-trigger"
  description = "Trigger parser on any new S3 object"
  event_pattern = jsonencode({
    "source" : ["aws.s3"],
    "detail-type" : ["Object Created"],
    "detail" : {
      "bucket" : {
        "name" : [aws_s3_bucket.fetcher_output.bucket]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "go_parser_target" {
  rule      = aws_cloudwatch_event_rule.parser_trigger.name
  target_id = "${local.prefix}go-parser"
  arn       = aws_lambda_function.go_parser_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge_go" {
  statement_id  = "AllowEventBridgeInvokeGoParser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.go_parser_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.parser_trigger.arn
}

resource "aws_cloudwatch_event_target" "perl_parser_target" {
  rule      = aws_cloudwatch_event_rule.parser_trigger.name
  target_id = "${local.prefix}perl-parser"
  arn       = aws_lambda_function.perl_parser_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge_perl" {
  statement_id  = "AllowEventBridgeInvokePerlParser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.perl_parser_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.parser_trigger.arn
}


