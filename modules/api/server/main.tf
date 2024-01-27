locals {
  name = "server"
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

variable "google_service_account" {
  description = "Google service account key"
  type        = string
  sensitive   = true
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
  description = "Configuration for API of Mailchimp"
  type = object({
    key = string
  })
}

variable "hydra_host" {
  type = string
}

variable "kratos_public_host" {
  type = string
}

variable "kratos_admin_host" {
  type = string
}

variable "kratos_secret" {
  type = string
}

variable "kratos_db_uri" {
  type = string
}

variable "serlo_org_database_layer_host" {
  type = string
}

variable "openai_api_key" {
  type = string
}

variable "swr_queue_dashboard" {
  description = "Basic auth credentials for SWR Queue dashboard"
  type = object({
    username = string
    password = string
  })
}

variable "notification_email_secret" {
  type = string
}

variable "enmeshed_server_host" {
  type = string
}

variable "enmeshed_server_secret" {
  type = string
}

variable "enmeshed_webhook_secret" {
  type = string
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
      target_port = 3001
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
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

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
          image             = "eu.gcr.io/serlo-shared/api-server:${var.image_tag}"
          name              = local.name
          image_pull_policy = var.image_pull_policy

          liveness_probe {
            http_get {
              path = "/health"
              port = 3001
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
            name  = "SERVER_HYDRA_HOST"
            value = var.hydra_host
          }

          env {
            name  = "SERVER_KRATOS_PUBLIC_HOST"
            value = var.kratos_public_host
          }

          env {
            name  = "SERVER_KRATOS_ADMIN_HOST"
            value = var.kratos_admin_host
          }

          env {
            name  = "SERVER_KRATOS_SECRET"
            value = var.kratos_secret
          }
          env {
            name  = "SERVER_KRATOS_DB_URI"
            value = var.kratos_db_uri
          }
          env {
            name  = "SERVER_SERLO_CLOUDFLARE_WORKER_SECRET"
            value = var.secrets.serlo_cloudflare_worker
          }

          env {
            name  = "SERVER_SWR_QUEUE_DASHBOARD_USERNAME"
            value = var.swr_queue_dashboard.username
          }

          env {
            name  = "SERVER_SWR_QUEUE_DASHBOARD_PASSWORD"
            value = var.swr_queue_dashboard.password
          }

          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/google_service_account/key.json"
          }

          env {
            name  = "SERVER_SERLO_NOTIFICATION_EMAIL_SERVICE_SECRET"
            value = var.notification_email_secret
          }

          env {
            name  = "ENMESHED_SERVER_HOST"
            value = var.enmeshed_server_host
          }

          env {
            name  = "ENMESHED_SERVER_SECRET"
            value = var.enmeshed_server_secret
          }

          env {
            name  = "ENMESHED_WEBHOOK_SECRET"
            value = var.enmeshed_webhook_secret
          }

          env {
            name  = "OPENAI_API_KEY"
            value = var.openai_api_key
          }

          volume_mount {
            mount_path = "/etc/google_service_account/key.json"
            sub_path   = "key.json"
            name       = "google-service-account-volume"
            read_only  = true
          }

          resources {
            limits = {
              cpu    = "600m"
              memory = "750Mi"
            }

            requests = {
              cpu    = "400m"
              memory = "500Mi"
            }
          }
        }

        volume {
          name = "google-service-account-volume"
          secret {
            secret_name = kubernetes_secret.google_service_account.metadata.0.name

            items {
              key  = "key.json"
              path = "key.json"
              mode = "0444"
            }
          }
        }
      }
    }
  }

  # Ignore changes to number of replicas since we have autoscaling enabled
  lifecycle {
    ignore_changes = [
      spec.0.replicas
    ]
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "server" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  spec {
    max_replicas = 5

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.name
    }
  }
}

resource "kubernetes_secret" "google_service_account" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  data = {
    "key.json" = var.google_service_account
  }
}
