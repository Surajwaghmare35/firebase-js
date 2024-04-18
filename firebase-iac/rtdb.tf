# # Provisions the default Realtime Database default instance.
# resource "google_firebase_database_instance" "database" {
#   provider = google-beta
#   project  = var.gcp_id
#   # See available locations: https://firebase.google.com/docs/projects/locations#rtdb-locations
#   region = var.region

#   # This value will become the first segment of the database's URL.
#   #   instance_id = "${var.gcp_id}-default-rtdb"
#   #   type        = "DEFAULT_DATABASE"
#   # desired_state = "ACTIVE"

#   instance_id   = "user-rtdb-${var.gcp_id}"
#   type          = "USER_DATABASE"
#   desired_state = "DISABLED"

#   # Wait for Firebase to be enabled in the Google Cloud project before initializing Realtime Database.
#   depends_on = [
#     google_project_service.default,
#   ]
# }
