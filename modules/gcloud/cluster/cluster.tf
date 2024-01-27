# Manages the Google Kubernetes Engine (GKE) cluster
#
# see https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "cluster" {
  name     = var.name
  location = var.location

  network    = google_compute_network.cluster.self_link
  subnetwork = google_compute_subnetwork.cluster.self_link

  # We dont't use the default node node pool, see warning at https://www.terraform.io/docs/providers/google/r/container_cluster.html#node_pool
  #
  # Since we can't create a cluster with no node pool defined, we create the smallest possible default node pool and
  # immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  enable_legacy_abac = true

  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.cluster.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.cluster.secondary_ip_range[1].range_name
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "01:00"
    }
  }

  release_channel {
    channel = "STABLE"
  }

  # Makes sure that the default node pool uses our custom Service Account, too
  node_config {
    service_account = google_service_account.cluster.email
  }

  # Don't recreate cluster when node config of default node pool changes since the default node pool is removed anyways
  lifecycle {
    ignore_changes = [
      node_config
    ]
  }
}


# Base64 encoded authentication information for accessing the k8s cluster
#
# see https://www.terraform.io/docs/providers/google/r/container_cluster.html#master_auth-0-client_certificate
# see https://www.terraform.io/docs/providers/google/r/container_cluster.html#master_auth-0-client_key
# see https://www.terraform.io/docs/providers/google/r/container_cluster.html#master_auth-0-cluster_ca_certificate
output "auth" {
  description = "Base64 encoded authentication information for accessing the k8s cluster"
  value       = google_container_cluster.cluster.master_auth[0]
  sensitive   = true
}


# The IP address of the clusters' k8s master
#
# see https://www.terraform.io/docs/providers/google/r/container_cluster.html#endpoint
output "endpoint" {
  description = "The IP address of the cluster's k8s master"
  value       = google_container_cluster.cluster.endpoint
}
