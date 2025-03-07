# Enable the IAM Workforce Identity Federation API
resource "google_project_service" "workload_identity" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  depends_on                = [google_project_service.workload_identity]
  provider                  = google
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "Github Actions Pool"
  description               = "Workload Identity Pool for Github Actions"
}

# Create Workload Identity Provider for Github OIDC
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  provider                           = google
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub OIDC Provider"
  description                        = "Allows Github Actions to authenticate using OIDC"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # This is how GKE knows to read what is in the token that gh actions provides.
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.actor"            = "assertion.actor"
    "attribute.aud"              = "assertion.aud"
  }

  # GH uses a single issuer URL - so some claims in the OIDC token may not be unique specifically to my deployment/org
  # These conditions are required to protect against spoofing - asserting that the action is from my repo and main branch
  attribute_condition = "assertion.repository_owner == '${var.github_owner}'"
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
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_owner}/${var.github_repo}"
  ]
}

# Allow the service account to create tokens
resource "google_service_account_iam_binding" "github_token_creator" {
  service_account_id = google_service_account.github_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_owner}/${var.github_repo}"
  ]
}

# Grant necessary GKE roles to the Service Account
resource "google_project_iam_member" "gke_roles" {
  for_each = toset([
    "roles/container.admin",         # Manage GKE clusters
    "roles/container.developer",     # Deploy workloads
    "roles/container.clusterViewer", # View cluster details
    "roles/container.clusterAdmin",  # Full access to GKE clusters

  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_sa.email}"
}


## Put values in Github Actions Secrets so the workflow can use them
data "github_actions_public_key" "gh_public_key" {
  repository = var.github_repo
}

resource "github_actions_secret" "gcp_project" {
  repository      = var.github_repo
  secret_name     = "GCP_PROJECT"
  plaintext_value = var.project_id
}

resource "github_actions_secret" "gcp_cluster_name" {
  repository      = var.github_repo
  secret_name     = "GKE_CLUSTER_NAME"
  plaintext_value = var.cluster_name
}

resource "github_actions_secret" "gcp_sa_email" {
  repository      = var.github_repo
  secret_name     = "GCP_SERVICE_ACCOUNT_EMAIL"
  plaintext_value = google_service_account.github_sa.email
}

resource "github_actions_secret" "wip_provider" {
  repository      = var.github_repo
  secret_name     = "GCP_WIP_PROVIDER"
  plaintext_value = "projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/providers/github-provider"
}

resource "github_actions_variable" "artifact_registry" {
  repository    = var.github_repo
  variable_name = "GAR_URL"
  value         = local.repository_url
}

resource "github_actions_variable" "static_ip" {
  repository    = var.github_repo
  variable_name = "STATIC_PUBLIC_IP"
  value         = google_compute_global_address.default.address
}
