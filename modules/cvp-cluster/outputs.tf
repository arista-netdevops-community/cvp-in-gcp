output "nodes" {
  value = google_compute_instance.cvp_nodes
}
output "node_ips" {
  value = google_compute_instance.cvp_nodes[*].network_interface.0.access_config.0.nat_ip
}
output "subnets" {
  value = data.google_compute_subnetwork.cvp_nodes
}
output "data_disk" {
  value = google_compute_disk.cvp_nodes
}
output "data_disk_attachment" {
  value = google_compute_instance.cvp_nodes[*].attached_disk.0.device_name
}