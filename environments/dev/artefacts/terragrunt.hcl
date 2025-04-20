include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../src//modules//artefacts"
}

locals {
  base = include.root.locals
}

inputs = {
  environment = local.base.environment
  aws_region  = local.base.aws_region
  bucket_name = local.base.artefact_bucket_name
}
