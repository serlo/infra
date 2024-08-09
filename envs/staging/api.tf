locals {
  api = {
    image_tags = {
      server           = "staging"
      api_db_migration = "1.2.0"
    }
  }
}

module "api_redis" {
  source = "../../modules/redis"

  namespace = kubernetes_namespace.api_namespace.metadata.0.name
  node_pool = module.cluster.node_pools.non-preemptible
}

module "api" {
  source = "../../modules/api"

  namespace         = kubernetes_namespace.api_namespace.metadata.0.name
  image_tag         = local.api.image_tags.server
  image_pull_policy = "Always"
  node_pool         = module.cluster.node_pools.non-preemptible

  environment = "staging"

  serlo_org_database_url = "mysql://serlo:${var.athene2_database_password_default}@${module.mysql.database_private_ip_address}:3306/serlo?timezone=+00:00"

  google_spreadsheet_api = {
    active_donors = var.api_active_donors_google_spreadsheet_id
    motivation    = var.api_motivation_google_spreadsheet_id
    secret        = var.api_active_donors_google_api_key
  }
  rocket_chat_api = {
    user_id    = var.rocket_chat_user_id
    auth_token = var.rocket_chat_auth_token
    url        = "https://community.serlo.org/"
  }
  mailchimp_api = {
    key = var.athene2_php_newsletter_key
  }
  redis_url   = "redis://redis-master:6379"
  slack_token = var.slack_token

  db_migration = {
    image_tag = local.api.image_tags.api_db_migration

    database_url = "mysql://serlo:${var.athene2_database_password_default}@${module.mysql.database_private_ip_address}:3306/serlo"
  }

  server = {
    hydra_host         = ""
    kratos_public_host = module.kratos.public_uri
    kratos_admin_host  = module.kratos.admin_uri
    kratos_secret      = module.kratos.secret
    kratos_db_uri      = "postgres://${local.postgres_database_username_default}:${var.kpi_kpi_database_password_default}@${module.gcloud_postgres.database_private_ip_address}/kratos"
    swr_queue_dashboard = {
      username = var.api_swr_queue_dashboard_username
      password = var.api_swr_queue_dashboard_password
    }
    google_service_account      = file("secrets/serlo-org-6bab84a1b1a5.json")
    sentry_dsn                  = "https://dd6355782e894e048723194b237baa39@o115070.ingest.sentry.io/5385534"
    enmeshed_server_host        = "http://enmeshed-connector-helm-chart"
    enmeshed_server_secret      = var.enmeshed_api_key
    enmeshed_webhook_secret     = var.enmeshed_api_key
    openai_api_key              = var.openai_api_key
    serlo_editor_testing_secret = var.serlo_editor_testing_secret
  }

  swr_queue_worker = {
    concurrency = 1
  }
}

module "enmeshed" {
  source = "../../modules/enmeshed"

  namespace              = kubernetes_namespace.api_namespace.metadata.0.name
  transport_base_url     = "https://nmshd-bkb.demo.meinbildungsraum.de/"
  platform_client_id     = var.enmeshed_platform_client_id
  platform_client_secret = var.enmeshed_platform_client_secret
  api_url                = "https://api.${local.domain}"
  api_key                = var.enmeshed_api_key
}

module "api_server_ingress" {
  source = "../../modules/ingress"

  name      = "api"
  namespace = kubernetes_namespace.api_namespace.metadata.0.name
  host      = "api.${local.domain}"
  backend = {
    service_name = module.api.server_service_name
    service_port = module.api.server_service_port
  }
  enable_tls  = true
  enable_cors = true
}

module "enmeshed_ingress" {
  source = "../../modules/ingress"

  name      = "enmeshed"
  namespace = kubernetes_namespace.api_namespace.metadata.0.name
  host      = "enmeshed.${local.domain}"
  backend = {
    service_name = "enmeshed-connector-helm-chart"
    service_port = 80
  }
  enable_tls = true
}

resource "kubernetes_namespace" "api_namespace" {
  metadata {
    name = "api"
  }
}
