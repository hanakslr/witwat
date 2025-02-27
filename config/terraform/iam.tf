provider "google" {
  project = var.project_id
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  provider                  = google
  project                   = var.project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "Github Actions Pool"
  description               = "Workload Identity Pool for Github Actions"
}

# Create Workload Identity Provider for Github OIDC
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  provider                           = google
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC Provider"
  description                        = "Allows Github Actions to authenticate using OIDC"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # This is how GKE knows to read what is in the token that gh actions provides.
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
  }
}

# Create a Service Account for GitHub Actions
resource "google_service_account" "github_sa" {
  account_id   = "github-deployer"
  display_name = "GitHub Actions Deployer"
}

# Allow Workload Identity Pool to assume this Service Account
resource "google_service_account_iam_binding" "github_wi_binding" {
  service_account_id = google_service_account.github_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
  ]
}

# Grant necessary GKE roles to the Service Account
resource "google_project_iam_member" "gke_roles" {
  for_each = toset([
    "roles/container.admin",    # Manage GKE clusters
    "roles/container.developer" # Deploy workloads
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_sa.email}"
}
