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

variable "parser_timeout_in_seconds" {
  description = "The number of seconds that the parser is allowed to run before failing."
  type        = number
  default     = 30
}

variable "parser_memory_size" {
  description = "The memory size of the parser lambda."
  type        = number
  default     = 256
}

variable "parser_version" {
  description = "The version of the Perl parser lambda to deploy."
  type        = string
}

variable "fetcher_schedule_expression" {
  description = "Schedule expression (rate or cron) for the fetcher Lambda"
  type        = string
  default     = "cron(0 6 * * ? *)" # 6 AM UTC daily
}

variable "sites_to_fetch" {
  type        = map(string)
  description = "Mapping of site names to URLs used by fetcher"
  default = {
    duckduckgo = "https://duckduckgo.com/jobs"
  }
}