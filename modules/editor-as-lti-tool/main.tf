locals {
  name      = "editor-as-lti-tool"
  image_tag = var.dev_mode ? "dev" : "latest"
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
            value = "mongodb://root:${random_password.mongodb_root_password.result}@editor-mongodb:27017/?authSource=admin&readPreference=primary&ssl=false"

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
