locals {
  cluster_node_list = flatten(var.nodes)
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
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${data.google_compute_instance.cluster_node[count.index].network_interface.0.access_config.0.nat_ip}, -u ${var.vm_admin_user} --private-key ${var.vm_private_ssh_key_path} ansible/cvp-provision.yaml"
  }
}