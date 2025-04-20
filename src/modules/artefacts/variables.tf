variable "bucket_name" {
  description = "Name of the S3 bucket to store lambda artefacts"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
}
