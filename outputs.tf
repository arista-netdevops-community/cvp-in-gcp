output "cvp_cluster_nodes_ips" {
  value =  module.cvp_provision_nodes.cluster_node[*].network_interface.0.access_config.0.nat_ip
}
output "cvp_cluster_ssh_user" {
  value =  module.cvp_provision_nodes.cluster_ssh_user
}
output "cvp_deviceadd_instructions" {
  value = "Provisioning complete. To add devices use the following TerminAttr configuration:\nexec /usr/bin/TerminAttr -ingestgrpcurl=${module.cvp_provision_nodes.cluster_node[0].network_interface.0.access_config.0.nat_ip}:9910 -cvcompression=gzip -ingestauth=${module.cvp_provision_nodes.cvp_ingest_key} -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent -ingestvrf=default -taillogs"
}