output "cluster_node" {
  value = data.google_compute_instance.cluster_node
}
output "cluster_ssh_user" {
  value = var.vm_admin_user
}
output "cvp_deviceadd_token" {
  value = data.external.cvp_token.result
}
output "cvp_ingest_key" {
  value = "key,${var.cvp_ingest_key}"
}