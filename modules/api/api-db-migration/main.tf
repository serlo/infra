locals {
  name = "api-db-migration"
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

variable "database_url" {
  type = string
}

variable "enable_cronjob" {
  type = bool
}

variable "redis_url" {
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
    active_deadline_seconds = 7200

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
          image             = "eu.gcr.io/serlo-shared/api-db-migration:${var.image_tag}"
          name              = local.name
          image_pull_policy = var.image_pull_policy

          env {
            name  = "DATABASE"
            value = var.database_url
          }

          env {
            name  = "REDIS_URL"
            value = var.redis_url
          }
        }
      }
    }
  }

  wait_for_completion = false
}

resource "kubernetes_cron_job_v1" "migration_cron_job" {
  count = var.enable_cronjob ? 1 : 0

  metadata {
    name      = "db-migration-cronjob"
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    concurrency_policy = "Forbid"
    schedule           = "0 5 * * *"
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
              name  = "db-migration-cronjob"
              image = "eu.gcr.io/serlo-shared/api-db-migration:${var.image_tag}"

              env {
                name  = "DATABASE"
                value = var.database_url
              }

              env {
                name  = "REDIS_URL"
                value = var.redis_url
              }
            }

            restart_policy = "Never"
          }
        }
      }
    }
  }
}
