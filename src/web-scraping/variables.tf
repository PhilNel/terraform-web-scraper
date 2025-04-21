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

variable "fetcher_timeout_in_seconds" {
  description = "The number of seconds that the fetcher is allowed to run before failing."
  type        = number
  default     = 30
}

variable "fetcher_memory_size" {
  description = "The memory size of the fetcher lambda."
  type        = number
  default     = 1024
}