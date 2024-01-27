# Reverses an external IP address that may be used by services that are externally accessible
#
# see https://www.terraform.io/docs/providers/google/r/compute_address.html
resource "google_compute_address" "cluster" {
  name   = var.name
  region = var.region
}

# The IP address
#
# see https://www.terraform.io/docs/providers/google/r/compute_address.html#address-1
output "address" {
  description = "External IP address that may be used by services that are externally accessible"
  value       = google_compute_address.cluster.address
}
