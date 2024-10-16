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

variable "slack_token" {
  type = string
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

variable "serlo_org_database_url" {
  type = string
}

variable "server" {
  description = "Configuration for server"
  type = object({
    hydra_host             = string
    kratos_public_host     = string
    kratos_admin_host      = string
    kratos_secret          = string
    kratos_db_uri          = string
    google_service_account = string
    swr_queue_dashboard = object({
      username = string
      password = string
    })
    sentry_dsn                  = string
    enmeshed_server_host        = string
    enmeshed_server_secret      = string
    enmeshed_webhook_secret     = string
    openai_api_key              = string
    serlo_editor_testing_secret = string
  })
}

variable "swr_queue_worker" {
  type = object({
    concurrency = number
  })
}

variable "db_migration" {
  type = object({
    image_tag    = string
    database_url = string
  })
}

module "secrets" {
  source = "./secrets"
}

module "server" {
  source = "./server"

  namespace         = var.namespace
  image_tag         = var.image_tag
  image_pull_policy = var.image_pull_policy
  node_pool         = var.node_pool

  environment                 = var.environment
  log_level                   = var.log_level
  redis_url                   = var.redis_url
  secrets                     = module.secrets
  sentry_dsn                  = var.server.sentry_dsn
  serlo_org_database_url      = var.serlo_org_database_url
  google_service_account      = var.server.google_service_account
  google_spreadsheet_api      = var.google_spreadsheet_api
  rocket_chat_api             = var.rocket_chat_api
  mailchimp_api               = var.mailchimp_api
  hydra_host                  = var.server.hydra_host
  kratos_public_host          = var.server.kratos_public_host
  kratos_admin_host           = var.server.kratos_admin_host
  kratos_secret               = var.server.kratos_secret
  kratos_db_uri               = var.server.kratos_db_uri
  openai_api_key              = var.server.openai_api_key
  swr_queue_dashboard         = var.server.swr_queue_dashboard
  enmeshed_server_host        = var.server.enmeshed_server_host
  enmeshed_server_secret      = var.server.enmeshed_server_secret
  enmeshed_webhook_secret     = var.server.enmeshed_webhook_secret
  serlo_editor_testing_secret = var.server.serlo_editor_testing_secret
}

module "swr_queue_worker" {
  source = "./swr-queue-worker"

  namespace         = var.namespace
  image_tag         = var.image_tag
  image_pull_policy = var.image_pull_policy
  node_pool         = var.node_pool

  environment            = var.environment
  log_level              = var.log_level
  redis_url              = var.redis_url
  secrets                = module.secrets
  sentry_dsn             = var.server.sentry_dsn
  google_spreadsheet_api = var.google_spreadsheet_api
  rocket_chat_api        = var.rocket_chat_api
  mailchimp_api          = var.mailchimp_api
  concurrency            = var.swr_queue_worker.concurrency
  serlo_org_database_url = var.serlo_org_database_url

}

module "api_db_migration" {
  source = "./db-migration"

  environment = var.environment
  namespace   = var.namespace
  image_tag   = var.db_migration.image_tag
  node_pool   = var.node_pool

  database_url   = var.db_migration.database_url
  redis_url      = var.redis_url
  slack_token    = var.slack_token
  slack_channel  = "C06LH10LNTY"
  openai_api_key = var.server.openai_api_key
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
