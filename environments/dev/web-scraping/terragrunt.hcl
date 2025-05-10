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
  parser_version  = "20250510-1236-b224b8e"
}