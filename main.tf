# TODO: Support remote states
terraform {
  required_version = ">= 0.13"
}

provider "google" {
  region = var.gcp_region
}

data "google_project" "project" {
  project_id = var.gcp_project_id
}

resource "random_string" "cvp_ingest_key" {
  length  = 16
  special = false
}

locals {
  centos = {
    version  = var.cvp_cluster_centos_version != null ? var.cvp_cluster_centos_version : (
        (var.cvp_version == "2020.1.0" || var.cvp_version == "2020.1.1" || var.cvp_version == "2020.1.2") ? "7.6" : (
          (var.cvp_version == "2020.2.0" || var.cvp_version == "2020.2.1" || var.cvp_version == "2020.2.2" || var.cvp_version == "2020.2.3" || var.cvp_version == "2020.2.4") ? "7.7" : (
            (var.cvp_version == "2020.3.0" || var.cvp_version == "2020.3.1") ? "7.7" : (
              (var.cvp_version == "2021.1.0") ? "7.7" : "7.7"
            )
          )
        )
      )
  }
  cvp_cluster = {
    vm_image = {
      location = local.centos.version == "7.7" ? "http://storage.googleapis.com/centos_minimal/centos-minimal-gcp77.tar.gz" : (
        var.cvp_cluster_centos_version == "7.6" ? "http://storage.googleapis.com/centos_minimal/centos-minimal-gcp76.tar.gz" : null
      )
    }
    zone = lower("${var.gcp_region}-${var.gcp_zone}")
  }
  cvp_ingest_key = var.cvp_ingest_key != null ? var.cvp_ingest_key : random_string.cvp_ingest_key.result
}

# TODO: support auto_create_subnetworks=false
resource "google_compute_network" "vpc_network" {
  count   = var.gcp_network == null ? 1 : 0
  name    = "vpc-${var.cvp_cluster_name}"
  project = var.gcp_project_id != null ? var.gcp_project_id : data.google_project.project.project_id
}

# TODO: Support instances in multiple zones
module "cvp_cluster" {
  source = "./modules/cvp-cluster"
  
  gcp_project_id   = var.gcp_project_id != null ? var.gcp_project_id : data.google_project.project.project_id
  gcp_region       = var.gcp_region
  gcp_network      = var.gcp_network != null ? var.gcp_network : google_compute_network.vpc_network[0].name

  cluster_name                     = var.cvp_cluster_name
  cluster_size                     = var.cvp_cluster_size
  cluster_zone                     = local.cvp_cluster.zone
  cluster_public_management        = var.cvp_cluster_public_management
  cluster_public_eos_communication = var.cvp_cluster_public_eos_communitation
  eos_ip_range                     = var.eos_ip_range
  vm_type                          = var.cvp_cluster_vm_type
  vm_image                         = local.cvp_cluster.vm_image.location
  vm_ssh_key                       = fileexists(var.cvp_cluster_vm_key) == true ? "${split(" ", file(var.cvp_cluster_vm_key))[0]} ${split(" ", file(var.cvp_cluster_vm_key))[1]}" : null
  vm_admin_user                    = var.cvp_cluster_vm_admin_user
  vm_remove_data_disk              = var.cvp_cluster_remove_disks
}
module "cvp_provision_nodes" {
  source = "git::https://gitlab.aristanetworks.com/tac-team/cvp-ansible-provisioning.git"

  gcp_project_id   = var.gcp_project_id != null ? var.gcp_project_id : data.google_project.project.project_id
  gcp_region       = var.gcp_region
  gcp_network      = var.gcp_network != null ? var.gcp_network : google_compute_network.vpc_network[0].name

  nodes                             = module.cvp_cluster.cluster_nodes
  vm_ssh_key                        = var.cvp_cluster_vm_key != null ? (fileexists(var.cvp_cluster_vm_key) == true ? file(var.cvp_cluster_vm_key) : null) : null
  vm_admin_user                     = var.cvp_cluster_vm_admin_user
  vm_private_ssh_key                = var.cvp_cluster_vm_private_key != null ? (fileexists(var.cvp_cluster_vm_private_key) == true ? file(var.cvp_cluster_vm_private_key) : null) : null
  vm_private_ssh_key_path           = var.cvp_cluster_vm_private_key != null ? (fileexists(var.cvp_cluster_vm_private_key) == true ? var.cvp_cluster_vm_private_key : null) : null
  vm_password                       = var.cvp_cluster_vm_password != null ? var.cvp_cluster_vm_password : null
  cvp_version                       = var.cvp_version
  cvp_download_token                = var.cvp_download_token
  cvp_install_size                  = var.cvp_install_size != null ? var.cvp_install_size : null
  cvp_enable_advanced_login_options = var.cvp_enable_advanced_login_options
  cvp_ingest_key                    = local.cvp_ingest_key
  cvp_k8s_cluster_network           = var.cvp_k8s_cluster_network
  cvp_ntp                           = var.cvp_ntp
}