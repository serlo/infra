variable "database_instance_name" {
  description = "Name for database instance in GCP."
  type        = string
}

variable "database_names" {
  description = "Name for databases in GCP."
  type        = list(string)
}

variable "database_connection_name" {
  description = "Name for database connection in GCP."
  type        = string
}

variable "database_region" {
  description = "Region for database."
  type        = string
}

variable "database_tier" {
  default     = "db-f1-micro"
  description = "Tier for database. See https://cloud.google.com/sql/pricing#2nd-gen-pricing"
  type        = string
}

variable "database_password_postgres" {
  description = "Password for default postgres database user."
  type        = string
}

variable "database_username_default" {
  description = "Username for default database user."
  type        = string
}

variable "database_password_default" {
  description = "Username for default database user."
  type        = string
}

variable "database_username_readonly" {
  description = "Username for readonly database user."
  type        = string
}

variable "database_password_readonly" {
  description = "Password for readonly database user."
  type        = string
}

variable "database_private_network" {
  description = "The name or self_link of the Google Compute Engine private network to which the database is connected."
  type        = string
}
