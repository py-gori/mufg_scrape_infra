# Mufg Scrape Infra

MUFG 確定拠出年金サイトをスクレイピングする Docker イメージを使用し  
GCP Cloud Run に環境を構築します。

## Overview

Cloud Scheduler にて週に 1 回定期的にトリガーし Pub/Sub トピックへリクエスト、  
Pub/Sub から Cloud Run へ Push します。  
Cloud Run サービス実行失敗時は 5 分後に 1 回のみリトライし、失敗時も LINE に通知します。

## Architecture

- Production
  ![mufg_scrape_image_prd drawio](https://user-images.githubusercontent.com/52909397/205480111-873e1be4-ea65-4f84-a0d3-20246174b8bd.png)

## Components

mufg_scrape_image リポジトリを参照して下さい  
https://github.com/py-gori/mufg_scrape_image
