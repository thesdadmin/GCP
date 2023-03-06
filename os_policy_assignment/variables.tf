variable "project" {
    description = "GCP Project"
}

variable "gcs_media_bkt" {
    description = "GCS Bucket to hold scripts and PS Modules"
}

variable "gcs_sql_bkt" {
    description = "GCS Bucket for SQL Full backups"
}

variable "gcs_sql_bkt_diff" {
    description = "GCS Bucket for SQL DIFF Backups"
}

variable "os_file_policy_assignment_name" {
    description = "File OS Policy Assignment"
}

variable "os_sql_policy_assignment_name" {
    description = "SQL OS Policy Assignment"
}

variable "region" {
    description = "GCP region"
}

variable "zone" {
    description = "GCP Zone"
}