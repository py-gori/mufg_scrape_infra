# https://cloud.google.com/run/docs/tutorials/pubsub?hl=ja#terraform_2
resource "google_pubsub_topic" "mufg_scrape" {
  name     = "mufg-scrape-topic"
  project  = var.gcp_project
}

resource "google_project_service_identity" "pubsub_agent" {
  provider = google-beta
  project  = var.gcp_project
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_binding" "project_token_creator" {
  project = var.gcp_project
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_project_service_identity.pubsub_agent.email}"]
}

resource "google_pubsub_subscription" "mufg_scrape" {
  name    = "mufg-scrape-subscription"
  project = var.gcp_project
  topic   = google_pubsub_topic.mufg_scrape.name
  push_config {
    push_endpoint = google_cloud_run_service.mufg_scrape.status[0].url
    oidc_token {
      service_account_email = google_service_account.pubsub.email
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
  retry_policy {
    minimum_backoff = "300s"
    maximum_backoff = "600s"
  }
  ack_deadline_seconds = 600
  message_retention_duration = "600s"
  depends_on = [google_cloud_run_service.mufg_scrape]
}