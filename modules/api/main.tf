variable "namespace" {
  description = "Kubernetes namespace to use"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to use"
  type        = string
}

variable "image_pull_policy" {
  description = "image pull policy"
  type        = string
}

variable "node_pool" {
  type        = string
  description = "Node pool to use"
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "google_spreadsheet_api" {
  description = "Configuration for Google Spreadsheet API"
  type = object({
    active_donors = string
    motivation    = string
    secret        = string
  })
}

variable "rocket_chat_api" {
  description = "Configuration for API of Rocket.Chat"
  type = object({
    user_id    = string
    auth_token = string
    url        = string
  })
}

variable "mailchimp_api" {
  description = "Configuration for API of Mailchimp"
  type = object({
    key = string
  })
}

variable "log_level" {
  description = "log level"
  type        = string
  default     = "INFO"
}

variable "redis_url" {
  description = "Redis URL to use for Cache"
  type        = string
}

variable "server" {
  description = "Configuration for server"
  type = object({
    hydra_host                = string
    kratos_public_host        = string
    kratos_admin_host         = string
    kratos_secret             = string
    kratos_db_uri             = string
    google_service_account    = string
    notification_email_secret = string
    swr_queue_dashboard = object({
      username = string
      password = string
    })
    sentry_dsn              = string
    enmeshed_server_host    = string
    enmeshed_server_secret  = string
    enmeshed_webhook_secret = string
    openai_api_key          = string
  })
}

variable "swr_queue_worker" {
  description = "Configuration for SWR Queue worker"
  type = object({
    concurrency = number
  })
}

variable "database_layer" {
  description = "Configuration for Database Layer"
  type = object({
    image_tag = string

    database_url                   = string
    database_max_connections       = number
    sentry_dsn                     = string
    metadata_api_last_changes_date = string
  })
}

variable "api_db_migration" {
  description = "Configuration for the API database migration"
  type = object({
    image_tag      = string
    database_url   = string
    enable_cronjob = bool
  })
}

module "secrets" {
  source = "./secrets"
}

module "database_layer" {
  source = "./database-layer"

  namespace         = var.namespace
  image_tag         = var.database_layer.image_tag
  image_pull_policy = var.image_pull_policy
  node_pool         = var.node_pool

  environment                    = var.environment
  sentry_dsn                     = var.database_layer.sentry_dsn
  serlo_org_database_url         = var.database_layer.database_url
  database_max_connections       = var.database_layer.database_max_connections
  metadata_api_last_changes_date = var.database_layer.metadata_api_last_changes_date
}

module "server" {
  source = "./server"

  namespace         = var.namespace
  image_tag         = var.image_tag
  image_pull_policy = var.image_pull_policy
  node_pool         = var.node_pool

  environment                   = var.environment
  log_level                     = var.log_level
  redis_url                     = var.redis_url
  secrets                       = module.secrets
  sentry_dsn                    = var.server.sentry_dsn
  google_service_account        = var.server.google_service_account
  google_spreadsheet_api        = var.google_spreadsheet_api
  rocket_chat_api               = var.rocket_chat_api
  mailchimp_api                 = var.mailchimp_api
  hydra_host                    = var.server.hydra_host
  kratos_public_host            = var.server.kratos_public_host
  kratos_admin_host             = var.server.kratos_admin_host
  kratos_secret                 = var.server.kratos_secret
  kratos_db_uri                 = var.server.kratos_db_uri
  serlo_org_database_layer_host = module.database_layer.host
  openai_api_key                = var.server.openai_api_key
  swr_queue_dashboard           = var.server.swr_queue_dashboard
  notification_email_secret     = var.server.notification_email_secret
  enmeshed_server_host          = var.server.enmeshed_server_host
  enmeshed_server_secret        = var.server.enmeshed_server_secret
  enmeshed_webhook_secret       = var.server.enmeshed_webhook_secret
}

module "swr_queue_worker" {
  source = "./swr-queue-worker"

  namespace         = var.namespace
  image_tag         = var.image_tag
  image_pull_policy = var.image_pull_policy
  node_pool         = var.node_pool

  environment                   = var.environment
  log_level                     = var.log_level
  redis_url                     = var.redis_url
  secrets                       = module.secrets
  sentry_dsn                    = var.server.sentry_dsn
  google_spreadsheet_api        = var.google_spreadsheet_api
  rocket_chat_api               = var.rocket_chat_api
  mailchimp_api                 = var.mailchimp_api
  serlo_org_database_layer_host = module.database_layer.host
  concurrency                   = var.swr_queue_worker.concurrency
}

module "api_db_migration" {
  source = "./api-db-migration"

  namespace         = var.namespace
  image_tag         = var.api_db_migration.image_tag
  image_pull_policy = var.image_pull_policy
  node_pool         = var.node_pool
  enable_cronjob    = var.api_db_migration.enable_cronjob

  database_url = var.api_db_migration.database_url
  redis_url    = var.redis_url
}

output "server_service_name" {
  value = module.server.service_name
}

output "server_service_port" {
  value = module.server.service_port
}

output "server_host" {
  value = module.server.host
}

output "swr_queue_worker_service_name" {
  value = module.swr_queue_worker.service_name
}

output "swr_queue_worker_service_port" {
  value = module.swr_queue_worker.service_port
}

output "swr_queue_worker_host" {
  value = module.swr_queue_worker.host
}

output "secrets_serlo_cloudflare_worker" {
  value = module.secrets.serlo_cloudflare_worker
}

output "secrets_serlo_org" {
  value = module.secrets.serlo_org
}
