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
