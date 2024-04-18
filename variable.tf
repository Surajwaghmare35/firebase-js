variable "region" { default = "us-central1" }

variable "gcp_name" { default = "FirebaseCft" }

variable "gcp_id" { default = "firebasecft" }

variable "gcp_bill_ac" { default = "0199BB-27E70D-0A27AC" }

# # variable "gcs-backend" { default = "tf-state-stage-fb" }

variable "gcs_loc" { default = "US" }

variable "default_gcs" { default = "fb-webapp-stage" }

variable "firestoreDb_loc" { default = "nam5" } //us-central1

variable "appengine_gcs" { default = "gcp_id.appspot.com" }

variable "default_fb_site_id" { default = "fir-cft" }
# Above you can by exec: firebase hosting:sites:list --project firebasecft

variable "custom_domain" { default = "vijuedutech.com" }
