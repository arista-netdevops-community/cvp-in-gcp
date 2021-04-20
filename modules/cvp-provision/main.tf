locals {
  cluster_node_list  = flatten(var.nodes)
  vm_cpus   = tonumber(split("-", data.google_compute_instance.cluster_node[0].machine_type)[1])
  vm_memory = tonumber(split("-", data.google_compute_instance.cluster_node[0].machine_type)[2])

  vm_cpu_tier = (
    (local.vm_cpus >= 8 && local.vm_cpus < 16) ? 1 : (
      (local.vm_cpus >= 16 && local.vm_cpus < 28) ? 2 : (
        local.vm_cpus >= 28 ? 3 : 0
      )
    )
  )
  vm_memory_tier = (
    (local.vm_memory >= 16384 && local.vm_memory < 22528) ? 1 : (
      (local.vm_memory >= 22528 && local.vm_memory < 53248) ? 2 : (
        local.vm_memory >= 53248 ? 3 : 0
      )
    )
  )

  cvp_suggested_size = var.cvp_install_size != null ? var.cvp_install_size : (
    (local.vm_cpu_tier == 1 && local.vm_memory_tier == 1) ? "demo" : (
      (local.vm_cpu_tier == 1 && local.vm_memory_tier == 2) ? "small" : (
        (local.vm_cpu_tier == 2 && local.vm_memory_tier == 2) ? "production" : (
          (local.vm_cpu_tier == 3 && local.vm_memory_tier == 3) ? "prod_wifi" : "demo"
        )
      )
    )
  )
}

resource "random_password" "root" {
  length  = 16
  special = true
}

data "google_compute_instance" "cluster_node" {
  count = length(local.cluster_node_list)
  
  self_link = local.cluster_node_list[count.index]
}

# TODO: Use proper user and key (needs fixing the image)
resource "null_resource" "cluster_node" {
  count = var.vm_ssh_key != null ? length(data.google_compute_instance.cluster_node[*].network_interface.0.access_config.0.nat_ip) : 0

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install python3",
      "id -u ${var.vm_admin_user} &>/dev/null || sudo useradd -m ${var.vm_admin_user} && sudo mkdir -p /home/${var.vm_admin_user}/.ssh && echo \"${var.vm_ssh_key}\" |sudo tee /home/${var.vm_admin_user}/.ssh/authorized_keys && sudo chown -R ${var.vm_admin_user}: /home/${var.vm_admin_user} && sudo echo \"${var.vm_admin_user} ALL=(ALL:ALL) NOPASSWD:ALL\" > /etc/sudoers.d/cvp-sudoers"
      #"echo ${random_password.root.result}|sudo passwd --stdin root"
    ]

    connection {
      host        = data.google_compute_instance.cluster_node[count.index].network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "root" #var.vm_admin_user
      #private_key = var.vm_private_ssh_key
      password    = "arastra"
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${data.google_compute_instance.cluster_node[count.index].network_interface.0.access_config.0.nat_ip}, -u ${var.vm_admin_user} --private-key ${var.vm_private_ssh_key_path} --extra-vars \"cvp_version=${var.cvp_version} api_token=${var.cvp_download_token} cvp_size=${local.cvp_suggested_size}\" ansible/cvp-provision.yaml"
  }
}