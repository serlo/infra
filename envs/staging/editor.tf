module "editor" {
  source = "../../modules/editor-as-lti-tool"

  namespace = kubernetes_namespace.editor_namespace.metadata.0.name
  node_pool = module.cluster.node_pools.non-preemptible

  dev_mode = true
}

module "editor_ingress" {
  source = "../../modules/ingress"

  name      = "editor"
  namespace = kubernetes_namespace.editor_namespace.metadata.0.name
  host      = "editor.${local.domain}"
  backend = {
    service_name = module.editor.editor_service_name
    service_port = module.editor.editor_service_port
  }
  enable_tls = true
}

resource "kubernetes_namespace" "editor_namespace" {
  metadata {
    name = "editor"
  }
}