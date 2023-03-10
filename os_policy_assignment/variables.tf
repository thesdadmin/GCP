## variables needed for provider

variable "project" {
  description = "GCP Project"
  
}
variable "region" {
  description = "GCP region"
}

variable "zone" {
  description = "GCP Zone"
}

## resource variables 

variable "gcs_media_bkt" {
  description = "GCS Bucket to hold scripts and PS Modules"
  default = "test-media-bkt"
}

variable "gcs_sql_bkt_full" {
  description = "GCS Bucket for SQL Full backups"
  default = "test-full-bkt"
}

variable "gcs_sql_bkt_diff" {
  description = "GCS Bucket for SQL DIFF Backups"
  default = "test-diff-bkt"
}

variable "os_file_policy_assignment_name" {
  description = "File OS Policy Assignment"
  default ="sql-file-policy"
}

variable "os_sql_policy_assignment_name" {
  description = "SQL OS Policy Assignment"
  default = "sql-policy-backups"
}

