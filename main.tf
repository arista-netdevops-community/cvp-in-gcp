terraform {
  required_version = ">= 0.13"
}

provider "google" {
  region = var.gcp_region
}

data "google_project" "project" {}

# TODO: support auto_create_subnetworks=false
resource "google_compute_network" "vpc_network" {
  count   = var.gcp_network == null ? 1 : 0
  name    = "vpc-${var.cvp_cluster_name}"
  project = data.google_project.project.project_id
}

# TODO:
#   - Support instances in multiple zones
module "cvp_cluster" {
  source = "./modules/cvp-cluster"
  
  gcp_project_id   = var.gcp_project_id
  gcp_region       = var.gcp_region
  gcp_network      = var.gcp_network != null ? var.gcp_network : google_compute_network.vpc_network[0].name

  cluster_name     = var.cvp_cluster_name
  cluster_size     = var.cvp_cluster_size
  vm_type          = var.cvp_cluster_vmtype
}