output "cluster_node" {
  value = data.google_compute_instance.cluster_node
}
output "cluster_ssh_user" {
  value = var.vm_admin_user
}