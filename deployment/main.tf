terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "> 6"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "europe-west1"
}

locals {
  enabled_services = [
    "privilegedaccessmanager.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "cloudasset.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}

// enable GCP project API
resource "google_project_service" "this" {
  for_each = toset(local.enabled_services)
  project  = var.project_id
  service  = each.key
}

# Create Pub/Sub topic
resource "google_pubsub_topic" "this" {
  name = "pam-topic"
}

# Create Pub/Sub subscription
resource "google_pubsub_subscription" "this" {
  name  = "pam-subscription"
  topic = google_pubsub_topic.this.name
}

# Provides access so PAM can send messages to Pub/Sub
resource "google_project_iam_member" "privilegedaccessmanager_service_agent" {
  project = var.project_id
  role    = "roles/privilegedaccessmanager.serviceAgent"
  member  = "serviceAccount:service-org-${var.org_id}@gcp-sa-pam.iam.gserviceaccount.com"
}


// Tell cloud assets to send PAM messages to this topic
resource "google_cloud_asset_project_feed" "pam-asset-inventory-feed" {
  project         = var.project_id
  feed_id         = "pam-iam-inventory-feed"
  content_type    = "RESOURCE"
  billing_project = var.project_id

  asset_types = [
    "privilegedaccessmanager.googleapis.com/Grant",
  ]

  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.this.name
    }
  }
}

resource "google_privileged_access_manager_entitlement" "pubsub_editor" {
  entitlement_id       = "pubsub-editor-entitlement"
  location             = "global"
  max_request_duration = "28800s" // 8 hours
  parent               = "projects/${var.project_id}"

  requester_justification_config {
    unstructured {}
  }

  eligible_users {
    principals = var.eligible_principals
  }

  privileged_access {
    gcp_iam_access {
      role_bindings {
        role = "roles/pubsub.editor"
        //condition_expression = 
      }
      resource      = "//cloudresourcemanager.googleapis.com/projects/${var.project_id}"
      resource_type = "cloudresourcemanager.googleapis.com/Project"
    }
  }

  approval_workflow {
    manual_approvals {
      require_approver_justification = false
      steps {
        approvers {
          principals = var.approver_principals
        }
      }
    }
  }
}
