# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  user_project_override = true
  region                = var.region
}

# Configures the provider to not use the resource block's specified project for quota checks.
# This provider should only be used during project creation and initializing services.
provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = false
  region                = var.region
}

# # Creates a new Google Cloud project.
# resource "google_project" "default" {
#   # Use the provider that enables the setup of quota checks for a new project
#   provider = google-beta.no_user_project_override

#   name       = var.gcp_name
#   project_id = var.gcp_id

#   # Required for any service that requires the Blaze pricing plan
#   # (like Firebase Authentication with GCIP)
#   # billing_account = "000000-000000-000000"
#   billing_account = var.gcp_bill_ac

#   # Required for the project to display in any list of Firebase projects.
#   labels = {
#     "firebase" = "enabled"
#   }
# }

# Enables required APIs.
resource "google_project_service" "default" {
  # Use the provider without quota checks for enabling APIS
  provider = google-beta.no_user_project_override
  # project  = google_project.default.project_id
  project = var.gcp_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "firebase.googleapis.com",
    # Enabling the ServiceUsage API allows the new project to be quota checked from now on.
    "serviceusage.googleapis.com",

    # For Authenticatio.
    "identitytoolkit.googleapis.com",

    # For RTDB.
    "firebasedatabase.googleapis.com",

    # For Firestore-DB.
    "firestore.googleapis.com",

    # For Storage.
    "firebaserules.googleapis.com",
    "firebasestorage.googleapis.com",
    "storage.googleapis.com",

    # For FirebaseExtensions.
    "firebaseextensions.googleapis.com",

    # On Firebase-Deploy ReqAll API's
    # For AppCheck
    "firebaseappcheck.googleapis.com",

    # For AppEngine
    "appenginereporting.googleapis.com",
    "appengine.googleapis.com",

    # For ComputeEngine
    "compute.googleapis.com",

    # For CloudFunction
    "cloudfunctions.googleapis.com",

    # For ArtifactRegistry
    "artifactregistry.googleapis.com",

  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

# Enables Firebase services for the new project created above.
# This action essentially "creates a Firebase project" and allows the project to use
# Firebase services (like Firebase Authentication) and
# Firebase tooling (like the Firebase console).

# Learn more about the relationship between Firebase projects and Google Cloud.
resource "google_firebase_project" "default" {
  # Use the provider that performs quota checks from now on
  provider = google-beta
  project  = var.gcp_id

  # Waits for the required APIs to be enabled.
  depends_on = [
    google_project_service.default
  ]
}

# Creates a Firebase Web App in the new project created above.
# Learn more about the relationship between Firebase Apps and Firebase projects.

resource "google_firebase_web_app" "basic" {
  provider     = google-beta
  project      = var.gcp_id
  display_name = var.gcp_name

  # The other App types (Android and Apple) use "DELETE" by default.
  # Web apps don't use "DELETE" by default due to backward-compatibility.
  deletion_policy = "DELETE"
}

data "google_firebase_web_app_config" "basic" {
  provider   = google-beta
  project    = var.gcp_id
  web_app_id = google_firebase_web_app.basic.app_id
}

output "appengine_gcs" {
  value = data.google_firebase_web_app_config.basic.storage_bucket
}

resource "google_storage_bucket" "default" {
  provider = google-beta
  project  = var.gcp_id
  name     = var.default_gcs
  location = var.gcs_loc
  # storage_class = "REGIONAL"
  force_destroy = true
}

resource "google_storage_bucket_object" "default" {
  provider = google-beta
  bucket   = google_storage_bucket.default.name
  name     = "firebase-config.json"

  content = jsonencode({
    appId             = google_firebase_web_app.basic.app_id
    apiKey            = data.google_firebase_web_app_config.basic.api_key
    authDomain        = data.google_firebase_web_app_config.basic.auth_domain
    databaseURL       = lookup(data.google_firebase_web_app_config.basic, "database_url", "")
    storageBucket     = lookup(data.google_firebase_web_app_config.basic, "storage_bucket", "")
    messagingSenderId = lookup(data.google_firebase_web_app_config.basic, "messaging_sender_id", "")
    measurementId     = lookup(data.google_firebase_web_app_config.basic, "measurement_id", "")
  })

  # Wait for Firebase to be enabled in the Google Cloud project before creating this WebApp.
  depends_on = [
    google_firebase_project.default,
  ]
}
