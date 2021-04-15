output "cvp_cluster_nodes" {  
  value = module.cvp_cluster.cluster_node[*]["https://www.googleapis.com/compute/v1/projects/cvp-tests/zones/us-central1-a/instances/my-cvp-cluster-g48h"].network_interface.0.access_config.0.nat_ip
}