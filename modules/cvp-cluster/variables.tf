variable "gcp_project_id" {
  description = "The name of the GCP Project where all resources will be launched."
  type        = string
  default     = null
}
variable "gcp_region" {
  description = "The region in which all GCP resources will be launched."
  type        = string
  default     = null
}
variable "gcp_network" {
  description = "The network in which clusters will be launched. Leaving this blank will create a new network."
  type        = string
}
variable "gcp_labels" {}

variable "cluster_name" {
  type = string
}
variable "cluster_size" {
  type = string
}
variable "cluster_zone" {
  type    = string
  default = null
}
variable "cluster_public_management" {
  type    = bool
  default = false
}

variable "vm_admin_user" {
  type    = string
  default = "cvpsshadmin"
}
variable "vm_disk_size" {
  type    = number
  default = 35
}
variable "vm_type" {
  type = string
}
variable "vm_image" {
  type = string
}
variable "vm_ssh_key" {
  type    = string
  default = null
}
variable "cluster_public_eos_communication" {
  type    = bool
  default = false
}
variable "eos_ip_range" {
  type    = list(any)
  default = []
}