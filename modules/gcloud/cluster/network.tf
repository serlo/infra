# Manages the VCP network used by the cluster
#
# see https://www.terraform.io/docs/providers/google/r/compute_network.html
resource "google_compute_network" "cluster" {
  name                    = var.name
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# see https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
# see https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
resource "google_compute_subnetwork" "cluster" {
  name                     = var.name
  region                   = var.region
  private_ip_google_access = true
  network                  = google_compute_network.cluster.self_link

  # IP address range for nodes, must not overlap with the ranges for pods or services
  ip_cidr_range = "10.0.0.0/20" # 10.0.0.0 - 10.0.15.255

  # IP adress range for pods, must not overlap with the ranges for nodes or services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.4.0.0/14" # 10.4.0.0 - 10.7.255.255
  }

  # IP address range for services, must not overlap with the ranges for nodes or pods
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.1.0.0/20" # 10.1.0.0 - 10.1.15.255
  }
}

# Configures private service access
#
# see https://www.terraform.io/docs/providers/google/r/service_networking_connection.html
# see https://cloud.google.com/vpc/docs/configure-private-services-access
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.cluster.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.reserved_peering_range.name]
}

# Reserves an internal IP address range that is used for VPC Network Peering to connect to Cloud SQL instances
#
# see https://www.terraform.io/docs/providers/google/r/compute_global_address.html
# see https://cloud.google.com/vpc/docs/vpc-peering
resource "google_compute_global_address" "reserved_peering_range" {
  name = "${var.name}-peering"

  # 10.8.0.0 - 10.11.255.255
  address       = "10.8.0.0"
  prefix_length = 14

  address_type = "INTERNAL"
  purpose      = "VPC_PEERING"
  network      = google_compute_network.cluster.self_link
}

output "network" {
  description = "VCP network used by the cluster"
  value       = google_compute_network.cluster.self_link
}
