resource "google_service_account" "cloud_run" {
  project      = var.gcp_project
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Secret Accessor"
}

resource "google_service_account" "pubsub" {
  project      = var.gcp_project
  account_id   = "cloud-run-pubsub-invoker"
  display_name = "Cloud Run Pub/Sub Invoker"
}

resource "google_project_iam_member" "sa_secret_accessor" {
  project = var.gcp_project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}
