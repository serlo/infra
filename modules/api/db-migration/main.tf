locals {
  name         = "db-migration"
  name_cronjob = "${local.name}-cronjob"
  image        = "eu.gcr.io/serlo-shared/api-db-migration:${var.image_tag}"
}

variable "namespace" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "node_pool" {
  type = string
}

variable "database_url" {
  type = string
}

variable "environment" {
  type = string
}

variable "redis_url" {
  type = string
}

variable "slack_channel" {
  type = string
}

variable "slack_token" {
  type = string
}

variable "openai_api_key" {
  type = string
}

resource "kubernetes_job" "migration" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        container {
          image             = local.image
          name              = local.name
          image_pull_policy = "Always"
          env_from {
            config_map_ref {
              name = kubernetes_config_map.envvars.metadata.0.name
            }
          }
        }
      }
    }
  }

  wait_for_completion = false
}

resource "kubernetes_cron_job_v1" "migration_cron_job" {
  count = var.environment == "staging" ? 1 : 0

  metadata {
    name      = local.name_cronjob
    namespace = var.namespace

    labels = {
      app = local.name_cronjob
    }
  }

  spec {
    concurrency_policy = "Forbid"
    schedule           = "0 3 * * *"
    job_template {
      metadata {}
      spec {
        backoff_limit = 2
        template {
          metadata {}
          spec {
            node_selector = {
              "cloud.google.com/gke-nodepool" = var.node_pool
            }

            container {
              name              = local.name_cronjob
              image             = local.image
              image_pull_policy = "Always"
              env_from {
                config_map_ref {
                  name = kubernetes_config_map.envvars.metadata.0.name
                }
              }
            }

            restart_policy = "Never"
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "envvars" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }
  data = {
    ENVIRONMENT    = var.environment
    MYSQL_URI      = var.database_url
    REDIS_URL      = var.redis_url
    SLACK_CHANNEL  = var.slack_channel
    SLACK_TOKEN    = var.slack_token
    OPENAI_API_KEY = var.openai_api_key
  }
}
