output "cvp_cluster_nodes_ips" {
  value =  module.cvp_provision_nodes.cluster_node[*].network_interface.0.access_config.0.nat_ip
}
output "cvp_cluster_ssh_user" {
  value =  module.cvp_provision_nodes.cluster_ssh_user
}