# Manages the Service Account used by the nodes in the cluster
#
# see https://www.terraform.io/docs/providers/google/r/google_service_account.html
# see https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa
resource "google_service_account" "cluster" {
  account_id   = var.name
  display_name = "Service account account for the GKE cluster"
}

resource "google_project_iam_member" "cluster_logWriter" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_metricWriter" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_monitoringViewer" {
  project = var.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}

resource "google_project_iam_member" "cluster_stackdriver_resourceMetadata_writer" {
  project = var.project
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.cluster.email}"
}
