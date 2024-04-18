# Provisions the Firestore database instance.
resource "google_firestore_database" "firestore" {
  provider = google-beta
  project  = var.gcp_id
  name     = "(default)"
  # See available locations: https://firebase.google.com/docs/projects/locations#default-cloud-location
  location_id = var.firestoreDb_loc // = us-central1
  # "FIRESTORE_NATIVE" is required to use Firestore with Firebase SDKs, authentication, and Firebase Security Rules.
  type             = "FIRESTORE_NATIVE"
  concurrency_mode = "OPTIMISTIC"

  app_engine_integration_mode       = "DISABLED"
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"
  delete_protection_state           = "DELETE_PROTECTION_DISABLED" // ENABLED
  deletion_policy                   = "DELETE"

  # Wait for Firebase to be enabled in the Google Cloud project before initializing Firestore.
  depends_on = [
    google_firebase_project.default,
  ]

  timeouts {
    create = "20m" // max : 60m
  }

}

# resource "time_sleep" "wait_60_seconds" {
#   depends_on      = [google_firestore_database.firestore]
#   create_duration = "60s"
# }

# Creates a ruleset of Firestore Security Rules from a local file.
resource "google_firebaserules_ruleset" "firestore" {
  provider = google-beta
  project  = var.gcp_id
  source {
    files {
      name = "firestore-prod.rules"
      # Write security rules in a local file named "firestore.rules".
      # Learn more: https://firebase.google.com/docs/firestore/security/get-started
      content     = file("${path.module}/firestore-prod.rules")
      fingerprint = md5("${path.module}/firestore-prod.rules")

    }
  }

  # Wait for Firestore to be provisioned before creating this ruleset.
  depends_on = [
    google_firestore_database.firestore,
  ]
}

# Releases the ruleset for the Firestore instance.
resource "google_firebaserules_release" "firestore" {
  provider     = google-beta
  name         = "cloud.firestore" # must be cloud.firestore
  ruleset_name = google_firebaserules_ruleset.firestore.name
  project      = var.gcp_id

  # Wait for Firestore to be provisioned before releasing the ruleset.
  depends_on = [
    google_firestore_database.firestore,
  ]

  lifecycle {
    replace_triggered_by = [
      google_firebaserules_ruleset.firestore
    ]
  }
}

# # Adds a new Firestore index.
# resource "google_firestore_index" "indexes" {
#   provider = google-beta
#   project  = var.gcp_id

#   collection  = "quiz"
#   query_scope = "COLLECTION"

#   fields {
#     field_path = "question"
#     order      = "ASCENDING"
#   }

#   fields {
#     field_path = "answer"
#     order      = "ASCENDING"
#   }

#   # Wait for Firestore to be provisioned before adding this index.
#   depends_on = [
#     google_firestore_database.firestore,
#   ]
# }

# # Adds a new Firestore document with seed data.
# # Don't use real end-user or production data in this seed document.
# resource "google_firestore_document" "doc" {
#   provider    = google-beta
#   project     = var.gcp_id
#   collection  = "quiz"
#   document_id = "question-1"
#   fields      = "{\"question\":{\"stringValue\":\"Favorite Database\"},\"answer\":{\"stringValue\":\"Firestore\"}}"

#   # Wait for Firestore to be provisioned before adding this document.
#   depends_on = [
#     google_firestore_database.firestore,
#   ]
# }
