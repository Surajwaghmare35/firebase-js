# Use existing Identity Platform config.

resource "google_identity_platform_project_default_config" "default" {
  provider = google-beta
  project  = var.gcp_id

  sign_in {
    allow_duplicate_emails = true

    anonymous {
      enabled = true
    }

    email {
      enabled           = true
      password_required = false
    }

    phone_number {
      enabled = true
      test_phone_numbers = {
        "+11231231234" = "000000"
      }
    }
  }

  # Wait for identitytoolkit.googleapis.com to be enabled before initializing Authentication.
  depends_on = [
    google_project_service.default,
  ]
}

# # Creates an Identity Platform config.
# # Also enables Firebase Authentication with Identity Platform in the project if not.
# resource "google_identity_platform_config" "auth" {
#   provider = google-beta
#   #   project  = google_project.auth.project_id
#   project = var.gcp_id

#   # Auto-deletes anonymous users
#   autodelete_anonymous_users = true

#   # Configures local sign-in methods, like anonymous, email/password, and phone authentication.
#   sign_in {
#     allow_duplicate_emails = true

#     anonymous {
#       enabled = true
#     }

#     email {
#       enabled           = true
#       password_required = false
#     }

#     phone_number {
#       enabled = true
#       test_phone_numbers = {
#         "+11231231234" = "000000"
#       }
#     }
#   }

# # Sets an SMS region policy.
# sms_region_config {
#   allowlist_only {
#     allowed_regions = [
#       "US",
#       "CA",
#     ]
#   }
# }

# # Configures blocking functions.
# blocking_functions {
#   triggers {
#     event_type = "beforeSignIn"
#     #   function_uri = "https://us-east1-${google_project.auth.project_id}.cloudfunctions.net/before-sign-in"
#     function_uri = "https://${var.region}-${var.gcp_id}.cloudfunctions.net/before-sign-in"
#   }
#   forward_inbound_credentials {
#     refresh_token = true
#     access_token  = true
#     id_token      = true
#   }
# }

# # Configures a temporary quota for new signups for anonymous, email/password, and phone number.
# quota {
#   sign_up_quota_config {
#     quota          = 1000
#     start_time     = ""
#     quota_duration = "7200s"
#   }
# }

# # Configures authorized domains.
# authorized_domains = [
#   "localhost",
#   # "${google_project.auth.project_id}.firebaseapp.com",
#   # "${google_project.auth.project_id}.web.app",
#   "${var.gcp_id}.firebaseapp.com",
#   "${var.gcp_id}.web.app",
# ]

#   # Wait for identitytoolkit.googleapis.com to be enabled before initializing Authentication.
#   depends_on = [
#     google_project_service.default,
#   ]
# }
