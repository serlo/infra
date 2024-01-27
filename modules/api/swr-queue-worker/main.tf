locals {
  name = "swr-queue-worker"
}

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

variable "log_level" {
  description = "log level"
  type        = string
}

variable "redis_url" {
  description = "Redis URL to use for Cache"
  type        = string
}

variable "secrets" {
  description = "Shared secrets between api.serlo.org and respective consumers"
  type = object({
    serlo_cloudflare_worker = string
    serlo_org               = string
  })
}

variable "sentry_dsn" {
  description = "Sentry DSN"
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
  description = "Configuration for API of Rocket.Chat"
  type = object({
    key = string
  })
}

variable "serlo_org_database_layer_host" {
  description = "Host of database layer"
  type        = string
}

variable "concurrency" {
  description = "Number of parallel requests"
  type        = number
}

resource "kubernetes_service" "server" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = local.name
    }

    port {
      port        = 3000
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

output "service_name" {
  value = kubernetes_service.server.metadata[0].name
}

output "service_port" {
  value = kubernetes_service.server.spec[0].port[0].port
}

output "host" {
  value = "http://${kubernetes_service.server.spec[0].cluster_ip}:${kubernetes_service.server.spec[0].port[0].port}/graphql"
}

resource "kubernetes_deployment" "server" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    selector {
      match_labels = {
        app = local.name
      }
    }

    strategy {
      type = "Recreate"
    }

    replicas = 1

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
          image             = "eu.gcr.io/serlo-shared/api-swr-queue-worker:${var.image_tag}"
          name              = local.name
          image_pull_policy = var.image_pull_policy

          liveness_probe {
            http_get {
              path = "/.well-known/health"
              port = 3000
            }

            initial_delay_seconds = 5
            period_seconds        = 30
          }

          env {
            name  = "ENVIRONMENT"
            value = var.environment
          }

          env {
            name  = "GOOGLE_SPREADSHEET_API_ACTIVE_DONORS"
            value = var.google_spreadsheet_api.active_donors
          }

          env {
            name  = "GOOGLE_SPREADSHEET_API_MOTIVATION"
            value = var.google_spreadsheet_api.motivation
          }

          env {
            name  = "GOOGLE_SPREADSHEET_API_SECRET"
            value = var.google_spreadsheet_api.secret
          }

          env {
            name  = "ROCKET_CHAT_API_USER_ID"
            value = var.rocket_chat_api.user_id
          }

          env {
            name  = "ROCKET_CHAT_API_AUTH_TOKEN"
            value = var.rocket_chat_api.auth_token
          }

          env {
            name  = "ROCKET_CHAT_URL"
            value = var.rocket_chat_api.url
          }

          env {
            name  = "MAILCHIMP_API_KEY"
            value = var.mailchimp_api.key
          }

          env {
            name  = "LOG_LEVEL"
            value = var.log_level
          }

          env {
            name  = "REDIS_URL"
            value = var.redis_url
          }

          env {
            name  = "SENTRY_DSN"
            value = var.sentry_dsn
          }

          env {
            name  = "SENTRY_RELEASE"
            value = var.image_tag
          }

          env {
            name  = "SERLO_ORG_DATABASE_LAYER_HOST"
            value = var.serlo_org_database_layer_host
          }

          env {
            name  = "SERLO_ORG_SECRET"
            value = var.secrets.serlo_org
          }

          env {
            name  = "SWR_QUEUE_WORKER_CONCURRENCY"
            value = var.concurrency
          }

          env {
            name  = "SWR_QUEUE_WORKER_DELAY"
            value = "250"
          }

          env {
            name  = "CHECK_STALLED_JOBS_DELAY"
            value = "600000"
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
}
