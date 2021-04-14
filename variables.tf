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
  default     = null
}

variable "cvp_cluster_name" {
  description = "The name of the CVP cluster"
  type        = string
}
variable "cvp_cluster_size" {
  description = "The number of nodes in the CVP cluster"
  type        = number

  validation {
    condition     = var.cvp_cluster_size != 1 || var.cvp_cluster_size != 3
    error_message = "The CVP cluster size must be 1 or 3 nodes."
  }
}
variable "cvp_cluster_vmtype" {
  description = "The type of instances used for CVP"
  type        = string
  default     = "custom-8-16384"
}