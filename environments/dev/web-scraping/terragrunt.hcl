include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../src//web-scraping"
}

locals {
  base = include.root.locals
}

inputs = {
  aws_region      = local.base.aws_region
  artefact_bucket = local.base.artefact_bucket_name
  environment     = local.base.environment
  parser_version  = "20250428-0711-5d70aa0"
}