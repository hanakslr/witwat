# GKE cluster
data "google_container_engine_versions" "gke_version" {
  location       = "${var.region}-b"
  version_prefix = "1.27."
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
  location = "${var.region}-b"
  cluster  = google_container_cluster.primary.name

  version    = data.google_container_engine_versions.gke_version.release_channel_default_version["STABLE"]
  node_count = var.node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = var.machine_type
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
