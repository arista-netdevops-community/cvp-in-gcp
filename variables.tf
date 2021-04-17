variable "gcp_project_id" {
  description = "The name of the GCP Project where all resources will be launched."
  type        = string
  default     = null
}
variable "gcp_region" {
  # TODO: Write a nice regex to validate region names
  description = "The region in which all GCP resources will be launched."
  type        = string
}
variable "gcp_network" {
  description = "The network in which clusters will be launched. Leaving this blank will create a new network."
  type        = string
  default     = null
}
variable "gcp_zone" {
  description = "The zone in which all GCP resources will be launched."
  type        = string

  validation {
    condition = length(var.gcp_zone) == 1 && can(regex("[a-zA-z]", var.gcp_zone))
    error_message = "The zone should be a letter matching the regex [a-z]."
  }
}

variable "cvp_cluster_name" {
  description = "The name of the CVP cluster"
  type        = string
}
variable "cvp_cluster_size" {
  description = "The number of nodes in the CVP cluster"
  type        = number

  validation {
    condition     = var.cvp_cluster_size == "1" || var.cvp_cluster_size == "3"
    error_message = "The CVP cluster size must be 1 or 3 nodes."
  }
}
variable "cvp_cluster_vm_type" {
  description = "The type of instances used for CVP"
  type        = string
  default     = "custom-8-16384"
}
variable "cvp_cluster_centos_version" {
  description = "The Centos version used by CVP instances."
  type        = string
  default     = "7.7"

  validation {
    condition     = var.cvp_cluster_centos_version != "7.6" || var.cvp_cluster_centos_version != "7.7"
    error_message = "Currently supported Centos versions are 7.6 or 7.7."
  }
}
variable "cvp_cluster_public_management" {
  description = "Whether the cluster management interface (https/ssh) is publically accessible over the internet"
  type        = bool
  default     = false
}
variable "cvp_cluster_vm_admin_user" {
  description = "User that will be used to connect to CVP cluster instances."
  type        = string
  default     = "cvpsshadmin"

  validation {
    condition = var.cvp_cluster_vm_admin_user != "cvpadmin"
    error_message = "The cvpadmin user is reserved and cannot be used."
  }
}
variable "cvp_cluster_vm_key" {
  description = "Public SSH key used to access instances in the CVP cluster."
  type        = string
  default     = null
}
variable "cvp_cluster_vm_private_key" {
  description = "Private SSH key used to access instances in the CVP cluster."
  type        = string
  default     = null
}
variable "cvp_cluster_vm_password" {
  description = "Password used to access instances in the CVP cluster."
  type        = string
  default     = null
}
variable "cvp_cluster_remove_disks" {
  description = "Whether data disks created for the instances will be removed when destroying them."
  type        = bool
  default     = false
}