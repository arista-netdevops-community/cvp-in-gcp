data "google_project" "project" {
  project_id = var.gcp_project_id
}

data "google_compute_instance_group" "cvp_cluster" {
  self_link = google_compute_instance_group_manager.cvp_nodes.instance_group
}

locals {
  cluster_node_list = flatten(data.google_compute_instance_group.cvp_cluster.instances)
}

data "google_compute_instance" "cluster_node" {
  count = length(flatten(data.google_compute_instance_group.cvp_cluster.instances))
  
  self_link = local.cluster_node_list[count.index]
}