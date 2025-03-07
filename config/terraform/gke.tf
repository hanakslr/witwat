# GKE cluster
data "google_container_engine_versions" "gke_version" {
  location       = "${var.region}-b"
  version_prefix = "1.27."
}

# Get project information
data "google_project" "project" {
  project_id = var.project_id
}

# Create a minimal GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = "${var.region}-b"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Prometheus monitoring takes a lot of cpu
  monitoring_config {
    managed_prometheus {
      enabled = false # Explicitly disable managed prometheus
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "${var.k8s_master_allowed_ip}/32"
    }
  }

  # Required for private clusters - GKE will auto-select appropriate ranges if not specified
  ip_allocation_policy {
    # Let GKE choose the ranges automatically
  }

  deletion_protection = false
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name     = google_container_cluster.primary.name
  version  = "1.31.5-gke.1169000"
  location = "${var.region}-b"
  cluster  = google_container_cluster.primary.name

  node_count = var.node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only" # Add this scope for container registry access
    ]

    labels = {
      env = var.project_id
    }

    machine_type = var.machine_type

    tags = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

## Our image artifact registry
# Enable the API
resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "image-repo" {
  location      = var.region
  repository_id = var.artifact_registry_repository_name
  description   = "Repository to host application images"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

# IAM policy for Artifact Registry using default compute service account
resource "google_artifact_registry_repository_iam_member" "gke_repository_access" {
  location   = google_artifact_registry_repository.image-repo.location
  repository = google_artifact_registry_repository.image-repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Project-level permissions for Artifact Registry
resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Additional permissions that might be needed
resource "google_project_iam_member" "storage_object_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Also we need to be explicit that this is the default node SA for the container
resource "google_project_iam_member" "default_container_sa" {
  project = var.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

### Hooking up the domain

# Reserve a static external IP address
resource "google_compute_global_address" "default" {
  name = "${var.project_id}-global-ip"
}

# Reference existing DNS zone using a data source
data "google_dns_managed_zone" "default" {
  name = var.cloud_dns_zone_name
}

# Add an A record pointing to our static IP
resource "google_dns_record_set" "default" {
  name         = "${var.domain_name}." # Note: must end with a dot
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.default.name
  rrdatas      = [google_compute_global_address.default.address]
}

# SSL Certificate
resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.project_id}-cert"
  managed {
    domains = [var.domain_name]
  }
}

# Output the static IP address
output "static_ip" {
  value = google_compute_global_address.default.address
}

# Output the repository URL for use in other configurations
output "repository_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.image-repo.repository_id}"
}

# Generate Helm values file
resource "local_file" "helm_values" {
  content = templatefile("${path.module}/helm-values.tftpl", {
    repository_url = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.image-repo.repository_id}/"
static_ip      = google_compute_global_address.default.address
    domain_name    = var.domain_name
    project_id     = var.project_id
  })
  filename = "${path.module}/../helm/secretValues.yaml"
}
