include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../src//modules//artefacts"
}

inputs = {
  environment = "dev"
  aws_region  = "af-south-1"
  bucket_name = "web-scraper-artefacts-dev-af-south-1"
}
