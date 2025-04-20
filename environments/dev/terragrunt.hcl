remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "web-scraping-terraform-state"
    key            = "dev/${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "web-scraping-terraform-locks"
  }
}

locals {
  aws_region           = "af-south-1"
  artefact_bucket_name = "web-scraper-artefacts-dev-af-south-1"
  environment          = "dev"
}