variable "artefact_bucket" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
}