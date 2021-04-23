locals {
  eos_range = var.cluster_public_eos_communication == true ? ["0.0.0.0/0"] : var.eos_ip_range
}

provider "google" {
  region = var.gcp_region
}

resource "google_compute_image" "centos" {
  name    = "cvp-centos-${var.cluster_name}"
  project = data.google_project.project.project_id

  raw_disk {
    source = var.vm_image
  }
}

resource "google_compute_instance_template" "cvp_nodes" {
  name                 = "template-${var.cluster_name}"
  description          = "This template is used to create CVP server instances."
  project              = data.google_project.project.project_id
  instance_description = "${var.cluster_name} instance"
  machine_type         = var.vm_type

  tags = ["arista-cvp-server"]

  labels = {
    app = "cvp"
  }

  metadata = {
    "ssh-keys" = var.vm_ssh_key != null ? "${var.vm_admin_user}:${var.vm_ssh_key}" : null
  }

  disk {
    source_image = google_compute_image.centos.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = 35
  }

  disk {
    auto_delete  = var.vm_remove_data_disk
    boot         = false
    disk_type    = "pd-ssd"
    disk_size_gb = 1024
    device_name  = "sdx"
  }

  network_interface {
    network = var.gcp_network
    access_config {}
  }
}

resource "google_compute_instance_group_manager" "cvp_nodes" {
  name               = "igm-cvp-nodes-${var.cluster_name}"
  project            = data.google_project.project.project_id
  base_instance_name = var.cluster_name
  zone               = var.cluster_zone

  version {
    instance_template  = google_compute_instance_template.cvp_nodes.id
  }

  target_size  = var.cluster_size

  named_port {
    name = "ssh"
    port = 22
  }
  named_port {
    name = "http"
    port = 80
  }
  named_port {
    name = "https"
    port = 443
  }
  named_port {
    name = "namenode"
    port = 8020
  }
  named_port {
    name = "namenode"
    port = 9001
  }
  named_port {
    name = "namenode"
    port = 15070
  }
  named_port {
    name = "datanode"
    port = 15010
  }
  named_port {
    name = "datanode"
    port = 15020
  }
  named_port {
    name = "datanode"
    port = 15075
  }
  named_port {
    name = "journalnode"
    port = 8480
  }
  named_port {
    name = "journalnode"
    port = 8481
  }
  named_port {
    name = "journalnode"
    port = 8485
  }
  named_port {
    name = "namenode-standby"
    port = 15090
  }
  named_port {
    name = "zookeeper"
    port = 2181
  }
  named_port {
    name = "zookeeper"
    port = 2888
  }
  named_port {
    name = "zookeeper"
    port = 3888
  }
  named_port {
    name = "zookeeper"
    port = 3889
  }
  named_port {
    name = "zookeeper"
    port = 3890
  }
  named_port {
    name = "zookeeper"
    port = 7070
  }
  named_port {
    name = "zookeeper-udp"
    port = 3888
  }
  named_port {
    name = "hbase-master"
    port = 16000
  }
  named_port {
    name = "hbase-master"
    port = 16010
  }
  named_port {
    name = "hbase-master"
    port = 7072
  }
  named_port {
    name = "hbase"
    port = 7073
  }
  named_port {
    name = "hadoop"
    port = 7074
  }
  named_port {
    name = "hadoop"
    port = 7075
  }
  named_port {
    name = "hadoop"
    port = 7076
  }
  named_port {
    name = "hadoop"
    port = 7077
  }
  named_port {
    name = "regionserver"
    port = 16201
  }
  named_port {
    name = "regionserver"
    port = 16301
  }
  named_port {
    name = "kafka"
    port = 9092
  }
  named_port {
    name = "kafka"
    port = 7078
  }
  named_port {
    name = "hazelcast"
    port = 5701
  }
  named_port {
    name = "ingest"
    port = 9910
  }
  named_port {
    name = "api-server"
    port = 9900
  }
  named_port {
    name = "api-server"
    port = 6063
  }
  named_port {
    name = "dispatcher"
    port = 9930
  }
  named_port {
    name = "dispatcher"
    port = 6064
  }
  named_port {
    name = "dispatcher2"
    port = 9931
  }
  named_port {
    name = "dispatcher2"
    port = 6065
  }
  named_port {
    name = "dispatcher3"
    port = 9932
  }
  named_port {
    name = "dispatcher3"
    port = 6066
  }
  named_port {
    name = "dispatcher4"
    port = 9933
  }
  named_port {
    name = "dispatcher4"
    port = 6067
  }
  named_port {
    name = "certs"
    port = 10093
  }
  named_port {
    name = "etc"
    port = 2379
  }
  named_port {
    name = "etc"
    port = 2380
  }
  named_port {
    name = "kubelet"
    port = 10250
  }
  named_port {
    name = "kube-apiserver"
    port = 6443
  }
  named_port {
    name = "elasticsearch"
    port = 9200
  }
  named_port {
    name = "elasticsearch"
    port = 9300
  }
  named_port {
    name = "clickhouse"
    port = 17040
  }
  named_port {
    name = "clickhouse"
    port = 17000
  }
  named_port {
    name = "change-control-api"
    port = 12010
  }
  named_port {
    name = "change-control-api"
    port = 12011
  }
  named_port {
    name = "clover"
    port = 12012
  }
  named_port {
    name = "clover"
    port = 12013
  }
  named_port {
    name = "prometheus"
    port = 9100
  }

  # auto_healing_policies {
  #   health_check      = google_compute_health_check.autohealing.id
  #   initial_delay_sec = 300
  # }
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

  source_ranges = [ "0.0.0.0/0" ]
  target_tags   = [ "arista-cvp-server" ]
}

resource "google_compute_firewall" "cvp_eos-cvp" {
  name        = "fw-cvp-${var.cluster_name}-eos-cvp"
  project     = data.google_project.project.project_id
  network     = var.gcp_network
  description = "Allow EOS->CVP communication"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "9910"]
  }

  source_ranges = local.eos_range
  target_tags   = [ "arista-cvp-server" ]
}

resource "google_compute_firewall" "cvp_cvp-cvp" {
  name        = "fw-cvp-${var.cluster_name}-cvp-cvp"
  project     = data.google_project.project.project_id
  network     = var.gcp_network
  description = "Allow CVP-CVP cluster communication"

  # Hadoop
  allow {
    protocol = "tcp"
    ports    = ["8020", "8485", "9001", "50010", "50020", "50070", "50075", "50090"]
  }

  # Hbase
  allow {
    protocol = "tcp"
    ports    = ["60000", "60010", "60020", "60030"]
  }

  # Zookeeper
  allow {
    protocol = "tcp"
    ports    = ["2181", "2888", "2889", "2890", "3888", "3889", "3890"]
  }

  source_tags   = [ "arista-cvp-server" ]
  target_tags   = [ "arista-cvp-server" ]
}