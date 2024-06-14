locals {
  name      = "editor-as-lti-tool"
  image_tag = var.dev_mode ? "dev" : "latest"

  lti_platform_url = "https://identityserver.itslearning.com"

}

variable "namespace" {
  type = string
}

variable "node_pool" {
  type = string
}

variable "dev_mode" {
  type = bool
}

variable "lti_platform_client_id" {
  type = string
}

output "editor_service_name" {
  value = kubernetes_service.editor_service.metadata[0].name
}

output "editor_service_port" {
  value = kubernetes_service.editor_service.spec[0].port[0].port
}

resource "kubernetes_deployment" "editor_as_lti_tool" {
  metadata {
    name      = local.name
    namespace = var.namespace

    labels = {
      app = local.name
    }
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        app = local.name
      }
    }

    template {
      metadata {
        labels = {
          app  = local.name
          name = local.name
        }
      }

      spec {
        node_selector = {
          "cloud.google.com/gke-nodepool" = var.node_pool
        }

        container {
          image             = "eu.gcr.io/serlo-shared/editor-as-lti-tool:${local.image_tag}"
          name              = local.name
          image_pull_policy = "Always"

          env {
            name  = "LTIJS_KEY"
            value = random_password.ltijs_key.result
          }

          env {
            name  = "MONGODB_CONNECTION_URI"
            value = "mongodb://root:${random_password.mongodb_root_password.result}@${helm_release.database.name}:27017/?authSource=admin&readPreference=primary&ssl=false"
          }
          env {
            name  = "LTI_PLATFORM_URL"
            value = local.lti_platform_url
          }
          env {
            name  = "LTI_PLATFORM_NAME"
            value = "itslearning.com"
          }
          env {
            name  = "LTI_PLATFORM_CLIENT_ID"
            value = var.lti_platform_client_id
          }
          env {
            name  = "LTI_PLATFORM_AUTHENTICATION_ENDPOINT"
            value = "${local.lti_platform_url}/connect/authorize"
          }
          env {
            name  = "LTI_PLATFORM_ACCESS_TOKEN_ENDPOINT"
            value = "${local.lti_platform_url}/connect/token"
          }
          env {
            name  = "LTI_PLATFORM_KEYSET_ENDPOINT"
            value = "${local.lti_platform_url}/.well-known/openid-configuration/jwks"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "editor_service" {
  metadata {
    name      = "editor-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = local.name
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "ClusterIP"
  }
}


resource "helm_release" "database" {
  name       = "editor-mongodb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "14.0.12"
  namespace  = var.namespace

  values = [
    templatefile(
      "${path.module}/values.yaml",
      {
        mongodb_root_password = random_password.mongodb_root_password.result
    })
  ]
}


resource "random_password" "mongodb_root_password" {
  length  = 32
  special = false
}

resource "random_password" "ltijs_key" {
  length  = 32
  special = false
}
