#### Set up default Cloud Storage default bucket after Firestore ####

# data "google_app_engine_default_service_account" "default" {
#   project    = var.gcp_id
#   depends_on = [google_app_engine_application.default, ]
# }

# output "default_account" {
#   value = data.google_app_engine_default_service_account.default.email
# }

# # Provisions the default Cloud Storage bucket for the project via Google App Engine.
# resource "google_app_engine_application" "default" {
#   provider = google-beta
#   project  = var.gcp_id
#   # See available locations: https://firebase.google.com/docs/projects/locations#default-cloud-location
#   # This will set the location for the default Storage bucket and the App Engine App.
#   location_id = var.region

#   # If you use Firestore, uncomment this to make sure Firestore is provisioned first.
#   depends_on = [
#     google_firestore_database.firestore
#   ]

#   lifecycle {
#     ignore_changes = [location_id, ]
#   }
# }

# Makes the default Storage bucket accessible for Firebase SDKs, authentication, and Firebase Security Rules.
resource "google_firebase_storage_bucket" "default-bucket" {
  provider = google-beta
  project  = var.gcp_id
  # bucket_id = google_app_engine_application.default.default_bucket

  # bucket_id = "${var.gcp_id}.appspot.com" // default appengine_gcs
  bucket_id = data.google_firebase_web_app_config.basic.storage_bucket // default appengine_gcs
}

# Creates a ruleset of Cloud Storage Security Rules from a local file.
resource "google_firebaserules_ruleset" "storage" {
  provider = google-beta
  project  = var.gcp_id
  source {
    files {
      # Write security rules in a local file named "storage.rules".
      # Learn more: https://firebase.google.com/docs/storage/security/get-started
      name        = "storage-prod.rules"
      content     = file("${path.module}/storage-prod.rules")
      fingerprint = md5("${path.module}/storage-prod.rules")
    }
  }

  # Wait for the default Storage bucket to be provisioned before creating this ruleset.
  depends_on = [
    google_firebase_project.default,
  ]
}

# # Releases the ruleset to the default Storage bucket.
# resource "google_firebaserules_release" "default-bucket" {
#   provider = google-beta
#   # name     = "firebase.storage/${google_app_engine_application.default.default_bucket}"

#   name = "firebase.storage/${google_firebase_storage_bucket.default-bucket.bucket_id}"
#   # name         = "firebase.storage/${var.gcp_id}.appspot.com"

#   ruleset_name = "projects/${var.gcp_id}/rulesets/${google_firebaserules_ruleset.storage.name}"
#   project      = var.gcp_id

#   lifecycle {
#     replace_triggered_by = [
#       google_firebaserules_ruleset.storage
#     ]
#   }
# }

# Uploads a new file to the default Storage bucket.
# Don't use real end-user or production data in this file.
resource "google_storage_bucket_object" "node-picture" {
  provider = google-beta
  name     = "nodejs.png"
  source   = "${path.module}/nodejs.png"
  # bucket   = google_app_engine_application.default.default_bucket

  bucket = google_firebase_storage_bucket.default-bucket.bucket_id
  # bucket = "${var.gcp_id}.appspot.com"
}
