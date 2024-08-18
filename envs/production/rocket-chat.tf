locals {
  rocket_chat = {
    chart_versions = {
      rocketchat = "4.7.4"
      mongodb    = "11.0.0"
    }
    image_tags = {
      rocketchat = "6.11.1"
      mongodb    = "5.0.24"
    }
  }
}

module "rocket-chat" {
  source = "../../modules/rocket-chat"

  host           = "community.${local.domain}"
  namespace      = kubernetes_namespace.community_namespace.metadata.0.name
  chart_versions = local.rocket_chat.chart_versions
  image_tags     = local.rocket_chat.image_tags
  node_pool      = module.cluster.node_pools.non-preemptible

  app_replicas = 1

  mongodump = {
    image         = "ghcr.io/serlo/infra/mongodb-tools:1.0.1"
    schedule      = "0 0 * * *"
    bucket_prefix = local.project
  }

  smtp_password = var.athene2_php_smtp_password
}

module "rocket-chat_ingress" {
  source = "../../modules/ingress"

  name      = "rocket-chat"
  namespace = kubernetes_namespace.community_namespace.metadata.0.name
  host      = "community.${local.domain}"
  backend = {
    service_name = "rocket-chat-rocketchat"
    service_port = 80
  }
  enable_tls = true
}

resource "kubernetes_namespace" "community_namespace" {
  metadata {
    name = "community"
  }
}
