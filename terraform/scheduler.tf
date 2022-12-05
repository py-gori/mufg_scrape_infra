resource "google_cloud_scheduler_job" "mufg_scrape_run" {
  project   = var.gcp_project
  region    = var.region
  name      = "${var.env}-scheduler-mufg_scrape_run"
  # every week monday AM08
  schedule  = "0 8 * * 1"
  time_zone = "Asia/Tokyo"

  pubsub_target {
    data       = base64encode("Runner")
    topic_name = google_pubsub_topic.mufg_scrape.id
  }
}