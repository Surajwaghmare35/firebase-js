# Terraform configuration to set up providers by version.

terraform {
  backend "gcs" {
    bucket = "tf-state-stage-fbcft"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_id
  region  = var.region
}

terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
      # version = "~> 4.0"
    }
  }
}

module "firebase" {
  source      = "./firebase-iac"
  region      = var.region
  gcp_name    = var.gcp_name
  gcp_id      = var.gcp_id
  gcp_bill_ac = var.gcp_bill_ac

  # gcs-backend        = var.gcs-backend
  gcs_loc            = var.gcs_loc
  default_gcs        = var.default_gcs
  firestoreDb_loc    = var.firestoreDb_loc
  appengine_gcs      = var.appengine_gcs
  default_fb_site_id = var.default_fb_site_id
  custom_domain      = var.custom_domain
}
