# # Installs an instance of the "Translate Text in Firestore" extension.
# # Or updates the extension if the specified instance already exists.
# resource "google_firebase_extensions_instance" "translation" {
#   provider = google-beta
#   project  = var.gcp_id

#   instance_id = "translate-text-in-firestore"
#   config {
#     extension_ref = "firebase/firestore-translate-text"

#     params = {
#       COLLECTION_PATH      = "posts/comments/translations"
#       DO_BACKFILL          = true
#       LANGUAGES            = "ar,en,es,de,fr"
#       INPUT_FIELD_NAME     = "input"
#       LANGUAGES_FIELD_NAME = "languages"
#       OUTPUT_FIELD_NAME    = "translated"
#     }

#     system_params = {
#       "firebaseextensions.v1beta.function/location"                   = var.region
#       "firebaseextensions.v1beta.function/memory"                     = "256"
#       "firebaseextensions.v1beta.function/minInstances"               = "0"
#       "firebaseextensions.v1beta.function/vpcConnectorEgressSettings" = "VPC_CONNECTOR_EGRESS_SETTINGS_UNSPECIFIED"
#     }
#   }
# }
