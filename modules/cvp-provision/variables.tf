variable "cvp_version" {
  type = string
}
variable "cvp_download_token" {
  type = string
}
variable "cvp_install_size" {
  type    = string
  default = null
}
variable "cvp_enable_advanced_login_options" {
  type    = bool
  default = false
}
variable "gcp_project_id" {}
variable "gcp_region" {}
variable "gcp_network" {}

variable "nodes" {}
variable "vm_ssh_key" {}
variable "vm_private_ssh_key" {
  type    = string
  default = null
}
variable "vm_private_ssh_key_path" {
  type    = string
  default = null
}
variable "vm_password" {
  type    = string
  default = null
}
variable "vm_admin_user" {}