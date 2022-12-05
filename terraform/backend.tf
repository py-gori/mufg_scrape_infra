terraform {
  backend "gcs" {
    prefix = "mufg-scrape-infra"
    # ファイル名はworkspace名.tfstateで生成される。
  }
}
