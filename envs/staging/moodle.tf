resource "helm_release" "moodle_deployment" {
  name       = "moodle"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "moodle"
  version    = "25.1.2"
  namespace  = kubernetes_namespace.moodle_namespace.metadata.0.name

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.hosts[0]"
    value = "moodle.serlo-staging.dev"
  }

  set {
    name  = "serviceType"
    value = "ClusterIP"
  }
}


resource "kubernetes_namespace" "moodle_namespace" {
  metadata {
    name = "moodle"
  }
}

resource "kubernetes_secret" "moodle_tls_certificate" {
  type = "kubernetes.io/tls"

  metadata {
    name      = "moodle-tls-secret"
    namespace = kubernetes_namespace.moodle_namespace.metadata.0.name
  }

  data = {
    "tls.crt" = module.cert.crt
    "tls.key" = module.cert.key
  }
}

module "cert" {
  source = "../../modules/tls-self-signed-cert"
  domain = "moodle.serlo-staging.dev"
}

module "moodle_ingress" {
  source = "../../modules/ingress"

  name      = "moodle"
  namespace = kubernetes_namespace.api_namespace.metadata.0.name
  host      = "moodle.${local.domain}"
  backend = {
    service_name = "moodle"
    service_port = 80
  }
  enable_tls = true
}
