variable "name" {
  description = "Name of the cluster and its managed resources"
  type        = string
}

variable "project" {
  description = "The Google Cloud project"
  type        = string
}

variable "location" {
  description = "The location (region or zone) in which the cluster's master will be created, as well as the default node location"
  type        = string
}

variable "region" {
  description = "The region in which the VCP network will be created"
  type        = string
}
