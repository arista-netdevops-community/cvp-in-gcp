locals {
  eos_range = var.cluster_public_eos_communication == true ? ["0.0.0.0/0"] : var.eos_ip_range
  gcp = {
    labels = var.gcp_labels
  }
  vm = {
    disk = {
      data = {
        device     = "sdx"
        type       = "pd-ssd"
        size       = 1024
      }
    }
  }
}

provider "google" {
  region = var.gcp_region
}

resource "google_compute_image" "centos" {
  name    = "cvp-centos-${var.cluster_name}"
  project = data.google_project.project.project_id
  labels  = local.gcp.labels

  raw_disk {
    source = var.vm_image
  }
}

resource "google_compute_disk" "cvp_nodes" {
  count   = var.cluster_size
  name    = "disk-${var.cluster_name}-${count.index}"
  project = data.google_project.project.project_id
  type    = local.vm.disk.data.type
  size    = local.vm.disk.data.size
  zone    = var.cluster_zone
  labels  = local.gcp.labels
}

resource "google_compute_instance" "cvp_nodes" {
  count        = var.cluster_size
  name         = "vm-${var.cluster_name}-${count.index}"
  project      = data.google_project.project.project_id
  zone         = var.cluster_zone
  description  = "${var.cluster_name} instance"
  machine_type = var.vm_type
  labels       = local.gcp.labels
  tags         = ["arista-cvp-server"]

  metadata = {
    "ssh-keys" = var.vm_ssh_key != null ? "${var.vm_admin_user}:${var.vm_ssh_key}" : null
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = google_compute_image.centos.self_link
      size  = 35
    }
  }
  attached_disk {
    source      = google_compute_disk.cvp_nodes[count.index].name
    device_name = local.vm.disk.data.device
  }
  network_interface {
    network = var.gcp_network
    access_config {}
  }
}

data "google_compute_subnetwork" "cvp_nodes" {
  count     = var.cluster_size
  self_link = google_compute_instance.cvp_nodes[count.index].network_interface.0.subnetwork
}

resource "google_compute_firewall" "cvp_management" {
  count       = var.cluster_public_management == true ? 1 : 0
  name        = "fw-cvp-${var.cluster_name}-mgmt"
  project     = data.google_project.project.project_id
  network     = var.gcp_network
  description = "Allow users to access CVP management interfaces."

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["arista-cvp-server"]
}

resource "google_compute_firewall" "cvp_eos-cvp" {
  name        = "fw-cvp-${var.cluster_name}-eos-cvp"
  project     = data.google_project.project.project_id
  network     = var.gcp_network
  description = "Allow EOS->CVP communication"

  allow {
    protocol = "tcp"
    ports = [
      "9910",
      "8443",
      "4433",
      "8090"
    ]
  }

  allow {
    protocol = "udp"
    ports = [
      "161",
      "3851"
    ]
  }

  source_ranges = local.eos_range
  target_tags   = ["arista-cvp-server"]
}

resource "google_compute_firewall" "cvp_cvp-cvp" {
  name        = "fw-cvp-${var.cluster_name}-cvp-cvp"
  project     = data.google_project.project.project_id
  network     = var.gcp_network
  description = "Allow CVP-CVP cluster communication. Obtained from /cvpi/tools/firewallConf.py --dumpPorts."

  allow {
    protocol = "tcp"
    ports = [
      "6090-6092",
      "7077",
      "9200",
      "7070",
      "9092",
      "2890",
      "17040",
      "17000",
      "10250",
      "9300",
      "5432",
      "9942",
      "6783",
      "7078",
      "7079",
      "9943",
      "7074",
      "15020",
      "2888",
      "2889",
      "2222",
      "7072",
      "7073",
      "2380",
      "16000",
      "9100",
      "6061",
      "6062",
      "6063",
      "3890",
      "8901",
      "2379",
      "16201",
      "19531",
      "580",
      "15090",
      "15010",
      "2181",
      "6443",
      "9001",
      "8020",
      "9093",
      "15075",
      "9900",
      "15070",
      "5443",
      "12012-12013",
      "3889",
      "3888",
      "8480",
      "8481",
      "9940",
      "9941",
      "8485",
      "9944",
      "7075",
      "7076"
    ]
  }

  allow {
    protocol = "udp"
    ports = [
      "694",
      "8472"
    ]
  }

  source_tags = ["arista-cvp-server"]
  target_tags = ["arista-cvp-server"]
}