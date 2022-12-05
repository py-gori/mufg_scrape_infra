resource "google_cloud_run_service" "mufg_scrape" {
  name     = "mufg-scrape"
  project  = var.gcp_project
  location = var.region

  template {
    spec {
      service_account_name  = google_service_account.cloud_run.email
      timeout_seconds       = 300
      container_concurrency = 10
      containers {
        image = "gcr.io/${var.gcp_project}/mufg_scrape${var.mufg_scrape_image_sha}"
        ports {
          container_port = 8080
        }
        resources {
          limits = {
            memory = "512Mi"
            cpu    = "1000m"
          }
        }
        env {
          name  = "SELENIUM_CHROME_URL"
          value = google_cloud_run_service.selenium_chrome.status[0].url
        }
        env {
          name  = "MUFG_UID"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = var.mufg_uid_secret_name
            }
          }
        }
        env {
          name  = "MUFG_PASS"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = var.mufg_pass_secret_name
            }
          }
        }
        env {
          name  = "LINE_TOKEN"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = var.line_token_secret_name
            }
          }
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "10"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [google_service_account.cloud_run, google_cloud_run_service.selenium_chrome]
}

resource "google_cloud_run_service" "selenium_chrome" {
  name     = "mufg-selenium-chrome"
  project  = var.gcp_project
  location = var.region

  template {
    spec {
      timeout_seconds       = 300
      container_concurrency = 10
      containers {
        image = "gcr.io/${var.gcp_project}/selenium_chrome${var.selenium_chrome_image_sha}"
        ports {
          container_port = 4444
        }
        resources {
          limits = {
            memory = "2Gi"
            cpu    = "1000m"
          }
        }
        env {
          name  = "SE_START_XVFB"
          value = "false"
        }
        env {
          name  = "START_XVFB"
          value = "false"
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "10"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "selenium_chrome" {
  project  = google_cloud_run_service.selenium_chrome.project
  location = google_cloud_run_service.selenium_chrome.location
  service  = google_cloud_run_service.selenium_chrome.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service_iam_binding" "mufg_scrape" {
  project  = google_cloud_run_service.mufg_scrape.project
  location = google_cloud_run_service.mufg_scrape.location
  service  = google_cloud_run_service.mufg_scrape.name
  role = "roles/run.invoker"
  members = [
    "serviceAccount:${google_service_account.pubsub.email}",
  ]
  depends_on = [google_service_account.pubsub]
}
