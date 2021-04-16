output "cvp_cluster_nodes_ips" {
  value = module.cvp_cluster.cluster_node[*].network_interface.0.access_config.0.nat_ip
}