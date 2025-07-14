variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "project_name" {
  description = "The name of the project (used for resource naming)"
  type        = string
  default     = "spike-cloud-run"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "asia-northeast1"
}

variable "database_name" {
  description = "The name of the PostgreSQL database"
  type        = string
  default     = "spike_db"
}

variable "database_user" {
  description = "The PostgreSQL database user"
  type        = string
  default     = "postgres"
}

variable "database_password" {
  description = "The PostgreSQL database password"
  type        = string
  sensitive   = true
}