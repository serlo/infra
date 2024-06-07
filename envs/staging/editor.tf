module "editor" {
  source = "../../modules/editor-as-lti-tool"

  namespace = kubernetes_namespace.api_namespace.metadata.0.name
  node_pool = module.cluster.node_pools.non-preemptible
}

module "editor_ingress" {
  source = "../../modules/ingress"

  name      = "editor"
  namespace = kubernetes_namespace.editor_namespace.metadata.0.name
  host      = "editor.${local.domain}"
  backend = {
    service_name = "editor"
    service_port = 80
  }
  enable_tls = true
}

resource "kubernetes_namespace" "editor_namespace" {
  metadata {
    name = "editor"
  }
}
