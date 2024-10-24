
resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "20.2.1"
  namespace  = var.namespace

  values = [
    templatefile(
      "${path.module}/values.yml",
      {
        node_pool = var.node_pool
      }
    )
  ]
}


variable "namespace" {
  type = string
}

variable "node_pool" {
  type = string
}
