variable "database_instance_name" {
  description = "Name for athene2 database instance in GCP."
}

variable "database_version" {
  type        = string
  description = "Database version to use"
}

variable "database_name" {
  description = "Name for athene2 database in GCP."
}

variable "database_connection_name" {
  type        = string
  description = "Name for athene2 database connection in GCP."
}

variable "database_region" {
  type        = string
  description = "Region for kpi database."
}

variable "database_tier" {
  type        = string
  description = "Tier for kpi database. See https://cloud.google.com/sql/pricing#2nd-gen-pricing"
  default     = "db-f1-micro"
}

variable "database_private_network" {
  description = "The name or self_link of the Google Compute Engine private network to which the database is connected."
}

variable "database_username_default" {
  type        = string
  description = "Username for default database user."
  default     = "serlo"
}

variable "database_password_default" {
  type        = string
  description = "Username for default database user."
}

variable "database_username_readonly" {
  type        = string
  description = "Username for readonly database user."
  default     = "serlo_readonly"
}

variable "database_password_readonly" {
  type        = string
  description = "Password for readonly database user."
}

variable "authorized_networks" {
  type        = list(object({ name = string, value = string }))
  default     = []
  description = "Autorized Networks for the database"
}
