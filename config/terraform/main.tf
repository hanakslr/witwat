terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}


provider "google" {
  project = var.project_id
  region  = var.region
}
