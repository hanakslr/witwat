variable "github_repo" {
  description = "GitHub repository in 'owner/repo' format"
  type        = string
}

variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "region" {
  description = "The region where resources will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for the nodes"
  type        = string
  default     = "e2-medium"
}

variable "k8s_master_allowed_ip" {
  description = "IP address allowed to access the k8s control plane"
  type        = string
}

variable "artifact_registry_repository_name" {
  description = "Name of the repo in the artifact registry for application images"
  type        = string
}

variable "cloud_dns_zone_name" {
  description = "The name of the Cloud DNS Zone. This project assumes that the DNS Zone has been provisioned out of band because it typically happens automatically when obtaining the domain."
  type        = string
}

variable "domain_name" {
  description = "The domain name to use for the application (e.g., example.com)"
  type        = string
}
