# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# Firewall rule for load balancer health checks and traffic
resource "google_compute_firewall" "allow_lb_health_checks" {
  name    = "${var.project_id}-allow-lb-health-checks"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"] # Allow HTTP/HTTPS for load balancer traffic and health checks
  }

  # Allow traffic from anywhere to your nodes
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gke-node", "${var.project_id}-gke"]

  direction = "INGRESS"
}
