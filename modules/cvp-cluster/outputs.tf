output "cluster_nodes" {
  value = data.google_compute_instance_group.cvp_cluster.instances
}
output "cluster_node" {
  value = data.google_compute_instance.cluster_node[*]
}