locals {
  ory_chart_version = "0.23.3"

  hydra = {
    image_tag = "v2.2.0"
  }

  kratos = {
    image_tag = "v1.3.0"
  }

}

module "hydra" {
  source = "../../modules/hydra"

  namespace     = kubernetes_namespace.auth_namespace.metadata.0.name
  chart_version = local.ory_chart_version
  image_tag     = local.hydra.image_tag
  node_pool     = module.cluster.node_pools.non-preemptible

  dsn         = "postgres://${var.postgres_username_default}:${var.kpi_kpi_database_password_default}@${module.gcloud_postgres.database_private_ip_address}/hydra"
  url_login   = "https://${local.domain}/auth/oauth/login"
  url_logout  = "https://${local.domain}/auth/oauth/logout"
  url_consent = "https://${local.domain}/auth/oauth/consent"
  host        = "hydra.${local.domain}"
}

module "kratos" {
  source = "../../modules/kratos"

  namespace          = kubernetes_namespace.auth_namespace.metadata.0.name
  dsn                = "postgres://${var.postgres_username_default}:${var.kpi_kpi_database_password_default}@${module.gcloud_postgres.database_private_ip_address}/kratos"
  host               = "kratos.${local.domain}"
  smtp_password      = var.athene2_php_smtp_password
  chart_version      = local.ory_chart_version
  image_tag          = local.kratos.image_tag
  domain             = local.domain
  nbp_client         = var.kratos_nbp_client
  vidis_client       = var.kratos_vidis_client
  vidis_issuer_url   = "https://aai.vidis.schule/auth/realms/vidis"
  newsletter_api_key = var.athene2_php_newsletter_key
}


resource "kubernetes_namespace" "auth_namespace" {
  metadata {
    name = "auth"
  }
}
