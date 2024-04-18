# resource "google_firebase_hosting_site" "default" {
#   provider = google-beta
#   project  = var.gcp_id
#   site_id  = "site-with-app" //site-with-channel/site-no-app/site-id-full
#   app_id   = google_firebase_web_app.basic.app_id
# }

resource "google_firebase_hosting_custom_domain" "default" {
  provider        = google-beta
  project         = var.gcp_id
  site_id         = var.default_fb_site_id
  custom_domain   = var.custom_domain
  cert_preference = "PROJECT_GROUPED" // GROUPED
  #   redirect_target = data.google_firebase_web_app_config.basic.auth_domain
  wait_dns_verification = false
}

resource "google_firebase_hosting_channel" "default" { //alt: full
  provider = google-beta
  #   site_id    = google_firebase_hosting_site.default.site_id
  site_id                = google_firebase_hosting_custom_domain.default.site_id
  channel_id             = "stage"  // alt : "channel-basic/full"
  ttl                    = "86400s" // default 1d=24h=86400s ,7d=604800s,14d,30d=2592000s
  retained_release_count = 10
  labels = {
    "webapp" : var.gcp_id
  }
}

resource "google_firebase_hosting_version" "default" {
  provider = google-beta
  site_id  = google_firebase_hosting_custom_domain.default.site_id
  #   config {
  #     redirects {
  #       glob        = "/google/**"
  #       status_code = 302
  #       location    = "https://www.google.com"
  #     }
  #   }
}

resource "google_firebase_hosting_release" "default" {
  provider     = google-beta
  site_id      = google_firebase_hosting_custom_domain.default.site_id
  channel_id   = google_firebase_hosting_channel.default.channel_id
  version_name = google_firebase_hosting_version.default.name
  message      = "Stage release" // in channel
}
