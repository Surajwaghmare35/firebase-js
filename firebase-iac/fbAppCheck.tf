# It takes a while for App Check to recognize the new app
# If your app already exists, you don't have to wait 30 seconds.

resource "time_sleep" "wait_30s" {
  depends_on      = [google_firebase_web_app.basic]
  create_duration = "30s"
}

resource "google_firebase_app_check_recaptcha_v3_config" "default" {
  provider = google-beta
  project  = var.gcp_id
  app_id   = google_firebase_web_app.basic.app_id
  # site_secret = "6Lf9YnQpAAAAAC3-MHmdAllTbPwTZxpUw5d34YzX"
  site_secret = google_firebase_web_app.basic.api_key_id
  token_ttl   = "7200s"

  depends_on = [time_sleep.wait_30s]
}
