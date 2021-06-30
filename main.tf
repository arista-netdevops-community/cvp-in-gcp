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
  gcp = {
    labels = {
      cvp-in-gcp_source  = "gitlab"
      cvp-in-gcp_version = "development_release"
    }
    image = {
      centos = {
        version = var.cvp_cluster_centos_version != null ? var.cvp_cluster_centos_version : (
          (var.cvp_version == "2020.1.0" || var.cvp_version == "2020.1.1" || var.cvp_version == "2020.1.2") ? "7.6" : (
            (var.cvp_version == "2020.2.0" || var.cvp_version == "2020.2.1" || var.cvp_version == "2020.2.2" || var.cvp_version == "2020.2.3" || var.cvp_version == "2020.2.4") ? "7.7" : (
              (var.cvp_version == "2020.3.0" || var.cvp_version == "2020.3.1") ? "7.7" : (
                (var.cvp_version == "2021.1.0" || var.cvp_version == "2021.1.1") ? "7.7" : "7.7"
              )
            )
          )
        )
      }
    }
  }
  vm_commons = {
    ssh = {
      username         = var.cvp_cluster_vm_admin_user
      private_key      = var.cvp_cluster_vm_private_key != null ? (fileexists(var.cvp_cluster_vm_private_key) == true ? file(var.cvp_cluster_vm_private_key) : null) : null
      private_key_path = var.cvp_cluster_vm_private_key != null ? (fileexists(var.cvp_cluster_vm_private_key) == true ? var.cvp_cluster_vm_private_key : null) : null
      public_key       = var.cvp_cluster_vm_key != null ? (fileexists(var.cvp_cluster_vm_key) == true ? file(var.cvp_cluster_vm_key) : null) : null
      public_key_path  = var.cvp_cluster_vm_key != null ? (fileexists(var.cvp_cluster_vm_key) == true ? var.cvp_cluster_vm_key : null) : null
    }
    bootstrap = {
      username = "root"
      password = "arastra"
    }
  }
  vm = length(module.cvp_cluster.nodes) == 1 ? ([
    {
      ssh       = local.vm_commons.ssh
      bootstrap = local.vm_commons.bootstrap
      disk = {
        data = {
          device = (
            "/dev/disk/by-id/scsi-0Google_PersistentDisk_${module.cvp_cluster.data_disk_attachment[0]}"
          )
        }
      }
      cpu = {
        number = split("-", module.cvp_cluster.nodes[0].machine_type)[1]
      }
      memory = {
        number = split("-", module.cvp_cluster.nodes[0].machine_type)[2]
      }
      network = {
        private = {
          address = module.cvp_cluster.nodes[0].network_interface.0.network_ip
          subnet = {
            netmask       = cidrnetmask(module.cvp_cluster.subnets[0].ip_cidr_range)
            default_route = module.cvp_cluster.subnets[0].gateway_address
          }
        }
        public = {
          address = module.cvp_cluster.nodes[0].network_interface.0.access_config.0.nat_ip
        }
      }
      config = {
        ntp = var.cvp_ntp
      }
    }
    ]) : ([
    {
      ssh       = local.vm_commons.ssh
      bootstrap = local.vm_commons.bootstrap
      disk = {
        data = {
          device = (
            "/dev/disk/by-id/scsi-0Google_PersistentDisk_${module.cvp_cluster.data_disk_attachment[0]}"
          )
        }
      }
      cpu = {
        number = split("-", module.cvp_cluster.nodes[0].machine_type)[1]
      }
      memory = {
        number = split("-", module.cvp_cluster.nodes[0].machine_type)[2]
      }
      network = {
        private = {
          address = module.cvp_cluster.nodes[0].network_interface.0.network_ip
          subnet = {
            netmask       = cidrnetmask(module.cvp_cluster.subnets[0].ip_cidr_range)
            default_route = module.cvp_cluster.subnets[0].gateway_address
          }
        }
        public = {
          address = module.cvp_cluster.nodes[0].network_interface.0.access_config.0.nat_ip
        }
      }
      config = {
        ntp = var.cvp_ntp
      }
    },
    {
      ssh       = local.vm_commons.ssh
      bootstrap = local.vm_commons.bootstrap
      disk = {
        data = {
          device = (
            "/dev/disk/by-id/scsi-0Google_PersistentDisk_${module.cvp_cluster.data_disk_attachment[1]}"
          )
        }
      }
      cpu = {
        number = split("-", module.cvp_cluster.nodes[1].machine_type)[1]
      }
      memory = {
        number = split("-", module.cvp_cluster.nodes[1].machine_type)[2]
      }
      network = {
        private = {
          address = module.cvp_cluster.nodes[1].network_interface.0.network_ip
          subnet = {
            netmask       = cidrnetmask(module.cvp_cluster.subnets[1].ip_cidr_range)
            default_route = module.cvp_cluster.subnets[1].gateway_address
          }
        }
        public = {
          address = module.cvp_cluster.nodes[1].network_interface.0.access_config.0.nat_ip
        }
      }
      config = {
        ntp = var.cvp_ntp
      }
    },
    {
      ssh       = local.vm_commons.ssh
      bootstrap = local.vm_commons.bootstrap
      disk = {
        data = {
          device = (
            "/dev/disk/by-id/scsi-0Google_PersistentDisk_${module.cvp_cluster.data_disk_attachment[2]}"
          )
        }
      }
      cpu = {
        number = split("-", module.cvp_cluster.nodes[2].machine_type)[1]
      }
      memory = {
        number = split("-", module.cvp_cluster.nodes[2].machine_type)[2]
      }
      network = {
        private = {
          address = module.cvp_cluster.nodes[2].network_interface.0.network_ip
          subnet = {
            netmask       = cidrnetmask(module.cvp_cluster.subnets[2].ip_cidr_range)
            default_route = module.cvp_cluster.subnets[2].gateway_address
          }
        }
        public = {
          address = module.cvp_cluster.nodes[2].network_interface.0.access_config.0.nat_ip
        }
      }
      config = {
        ntp = var.cvp_ntp
      }
    }
  ])
  cvp_cluster = {
    vm_image = {
      location = var.cvp_vm_image != null ? var.cvp_vm_image : (local.gcp.image.centos.version == "7.7" ? "http://storage.googleapis.com/centos_minimal/centos-minimal-gcp77.tar.gz" : (
        var.cvp_cluster_centos_version == "7.6" ? "http://storage.googleapis.com/centos_minimal/centos-minimal-gcp76.tar.gz" : null
      ))
    }
    zone = lower("${var.gcp_region}-${var.gcp_zone}")
  }
  cvp_ingest_key    = var.cvp_ingest_key != null ? var.cvp_ingest_key : random_string.cvp_ingest_key.result
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

  gcp_project_id = var.gcp_project_id != null ? var.gcp_project_id : data.google_project.project.project_id
  gcp_region     = var.gcp_region
  gcp_network    = var.gcp_network != null ? var.gcp_network : google_compute_network.vpc_network[0].name
  gcp_labels     = local.gcp.labels

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
}

module "cvp_provision_nodes" {
  source = "git::https://gitlab.aristanetworks.com/tac-team/cvp-ansible-provisioning.git"
  cloud_provider = "gcp"

  nodes                             = module.cvp_cluster.nodes
  subnets                           = module.cvp_cluster.subnets
  vm                                = local.vm
  cvp_version                       = var.cvp_version
  cvp_download_token                = var.cvp_download_token
  cvp_install_size                  = var.cvp_install_size != null ? var.cvp_install_size : null
  cvp_enable_advanced_login_options = var.cvp_enable_advanced_login_options
  cvp_ingest_key                    = local.cvp_ingest_key
  cvp_k8s_cluster_network           = var.cvp_k8s_cluster_network
}