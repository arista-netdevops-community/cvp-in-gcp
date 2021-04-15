terraform {
  required_version = ">= 0.13"
}

provider "google" {
  region = var.gcp_region
}

data "google_project" "project" {
  project_id = var.gcp_project_id
}

locals {
  cvp_cluster = {
    vm_image = {
      version  = var.cvp_cluster_centos_version
      location = var.cvp_cluster_centos_version == "7.7" ? "http://storage.googleapis.com/centos_minimal/centos-minimal-gcp77.tar.gz" : var.cvp_cluster_centos_version == "7.6" ? "http://storage.googleapis.com/centos_minimal/centos-minimal-gcp76.tar.gz" : null
    }
    zone = lower("${var.gcp_region}-${var.gcp_zone}")
  }
}

# TODO: support auto_create_subnetworks=false
resource "google_compute_network" "vpc_network" {
  count   = var.gcp_network == null ? 1 : 0
  name    = "vpc-${var.cvp_cluster_name}"
  project = var.gcp_project_id != null ? var.gcp_project_id : data.google_project.project.project_id
}

# TODO:
#   - Support instances in multiple zones
module "cvp_cluster" {
  source = "./modules/cvp-cluster"
  
  gcp_project_id   = var.gcp_project_id != null ? var.gcp_project_id : data.google_project.project.project_id
  gcp_region       = var.gcp_region
  gcp_network      = var.gcp_network != null ? var.gcp_network : google_compute_network.vpc_network[0].name

  cluster_name              = var.cvp_cluster_name
  cluster_size              = var.cvp_cluster_size
  cluster_zone              = local.cvp_cluster.zone
  cluster_public_management = var.cvp_cluster_public_management
  vm_type                   = var.cvp_cluster_vm_type
  vm_image                  = local.cvp_cluster.vm_image.location
  vm_ssh_key                = fileexists(var.cvp_cluster_vm_key) == true ? file(var.cvp_cluster_vm_key) : null
  vm_remove_data_disk       = var.cvp_cluster_remove_disks
}