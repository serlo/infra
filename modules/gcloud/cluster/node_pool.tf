variable "node_pools" {
  description = "Node pool configuration"
  type = map(object({
    machine_type       = string
    preemptible        = bool
    initial_node_count = number
    min_node_count     = number
    max_node_count     = number
    location_policy    = string
  }))
}

# Manages the node pool used by the Google Kubernetes Engine (GKE) cluster
#
# see https://www.terraform.io/docs/providers/google/r/container_node_pool.html
# see https://www.terraform.io/docs/providers/google/r/container_cluster.html#node_pool
resource "google_container_node_pool" "cluster" {
  for_each = var.node_pools

  name               = "${var.name}-${each.key}"
  location           = var.location
  cluster            = google_container_cluster.cluster.name
  initial_node_count = each.value.initial_node_count

  node_config {
    machine_type    = each.value.machine_type
    preemptible     = each.value.preemptible
    service_account = google_service_account.cluster.email

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  autoscaling {
    min_node_count  = each.value.min_node_count
    max_node_count  = each.value.max_node_count
    location_policy = each.value.location_policy
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

output "node_pools" {
  value = {
    for k, v in var.node_pools : k => "${var.name}-${k}"
  }
}
