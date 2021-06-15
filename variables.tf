variable "cvp_cluster_centos_version" {
  description = "The Centos version used by CVP instances."
  type        = string
  default     = null

  validation {
    condition     = var.cvp_cluster_centos_version != "7.6" || var.cvp_cluster_centos_version != "7.7" || var.cvp_cluster_centos_version != null
    error_message = "Currently supported Centos versions are 7.6 or 7.7."
  }
}
variable "cvp_cluster_name" {
  description = "The name of the CVP cluster"
  type        = string
}
variable "cvp_cluster_public_eos_communitation" {
  description = "Whether the ports used by EOS devices to communicate to CVP are publically accessible over the internet."
  type        = bool
  default     = false
}
variable "cvp_cluster_public_management" {
  description = "Whether the cluster management interface (https/ssh) is publically accessible over the internet."
  type        = bool
  default     = false
}
variable "cvp_cluster_remove_disks" {
  description = "Whether data disks created for the instances will be removed when destroying them."
  type        = bool
  default     = false
}
variable "cvp_cluster_size" {
  description = "The number of nodes in the CVP cluster"
  type        = number

  validation {
    condition     = var.cvp_cluster_size == "1" || var.cvp_cluster_size == "3"
    error_message = "The CVP cluster size must be 1 or 3 nodes."
  }
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
variable "cvp_cluster_vm_password" {
  description = "Password used to access instances in the CVP cluster."
  type        = string
  default     = null
}
variable "cvp_cluster_vm_private_key" {
  description = "Private SSH key used to access instances in the CVP cluster."
  type        = string
  default     = null
}
variable "cvp_cluster_vm_type" {
  description = "The type of instances used for CVP"
  type        = string
  default     = "custom-10-20480"
}
variable "cvp_download_token" {
  description = "Arista Portal token used to download CVP."
  type        = string
}
variable "cvp_enable_advanced_login_options" {
  description = "Whether to enable advanced login options on CVP."
  type        = bool
  default     = false
}
variable "cvp_ingest_key" {
  description = "Key that will be used to authenticate devices to CVP."
  type        = string
  default     = null
}
variable "cvp_install_size" {
  description = "CVP installation size."
  type        = string

  default     = null

  validation {
    condition = var.cvp_install_size == "demo" || var.cvp_install_size == "small" || var.cvp_install_size == "production" || var.cvp_install_size == "prod_wifi" || var.cvp_install_size == null
    error_message = "CVP install size must be one of 'demo', 'small', 'production' or 'prod_wifi'."
  }
}
variable "cvp_k8s_cluster_network" {
  description = "Internal network that will be used inside the k8s cluster. Applies only to 2021.1.0+."
  type        = string
  default     = "10.42.0.0/16"

  validation {
    condition     = (split(".", var.cvp_k8s_cluster_network)[0] != "169" || split(".", var.cvp_k8s_cluster_network)[1] != "254") && (split(".", var.cvp_k8s_cluster_network)[1] != "127")
    error_message = "The internal kubernetes network shouldn't be in the 169.254.0.0/16 or 127.0.0.0/8 ranges."
  }
}
variable "cvp_ntp" {
  description = "NTP server used to keep time synchronization between CVP nodes."
  type        = string
  default     = "time.google.com"
}
variable "cvp_version" {
  description = "CVP version to install on the cluster."
  type        = string
  default     = "2020.3.1"
}
variable "cvp_vm_image" {
  description = "Image used to launch VMs."
  type        = string
  default     = null
}

variable "eos_ip_range" {
  description = "IP ranges used by EOS devices that will be managed by the CVP cluster."
  type        = list
  default     = []
}

variable "gcp_network" {
  description = "The network in which clusters will be launched. Leaving this blank will create a new network."
  type        = string
  default     = null
}
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
variable "gcp_zone" {
  description = "The zone in which all GCP resources will be launched."
  type        = string

  validation {
    condition = length(var.gcp_zone) == 1 && can(regex("[a-zA-z]", var.gcp_zone))
    error_message = "The zone should be a letter matching the regex [a-zA-z]."
  }
}