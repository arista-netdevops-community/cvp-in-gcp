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

  # TODO: Allow users to specify the Wi-Fi cluster IP address
  cvp_wifi_cluster_ip = data.google_compute_instance.cluster_node[0].network_interface.0.network_ip

  cvp_k8s_cluster_network = var.cvp_k8s_cluster_network

  cvp_ntp = var.cvp_ntp
}

resource "random_password" "root" {
  length  = 16
  special = true
}
resource "random_id" "prefix" {
  byte_length = 8
}

data "google_compute_instance" "cluster_node" {
  count = length(local.cluster_node_list)
  
  self_link = local.cluster_node_list[count.index]
}

data "google_compute_subnetwork" "cluster_node" {
  self_link = data.google_compute_instance.cluster_node[0].network_interface.0.subnetwork
}

# TODO: Support multiple DNS servers
data "external" "cluster_node_data" {
  count = var.vm_ssh_key != null ? length(data.google_compute_instance.cluster_node[*].network_interface.0.access_config.0.nat_ip) : 0 
  program = [
    "ssh",
    "-tt",
    "-o UserKnownHostsFile=/dev/null",
    "-o StrictHostKeyChecking=no",
    "${var.vm_admin_user}@${data.google_compute_instance.cluster_node[count.index].network_interface.0.access_config.0.nat_ip}", 
    "echo \"{\\\"cvp_hostname\\\": \\\"$(hostname)\\\", \\\"cvp_default_route\\\": \\\"$(/sbin/ip route show|grep ^default|awk '{print $3}'|head -1)\\\", \\\"cvp_ip\\\": \\\"$(hostname -i)\\\", \\\"cvp_dns_domain\\\": \\\"$(hostname -d)\\\", \\\"cvp_net_interface\\\": \\\"$(/sbin/ip a |grep -B2 ${data.google_compute_instance.cluster_node[count.index].network_interface.0.network_ip}|head -1|cut -f2 -d:|xargs)\\\", \\\"cvp_dns\\\": \\\"$(grep nameserver /etc/resolv.conf |cut -f2 -d' ')\\\"}\""
  ]

  depends_on = [
    null_resource.cluster_node_user
  ]
}

resource "tls_private_key" "cvp_ssh" {
  algorithm = "RSA"
}

resource "local_file" "cvp_ssh_authorized_keys" {
  filename        = "${path.module}/dynamic/${random_id.prefix.hex}-cvp-id_rsa.pub"
  content         = tls_private_key.cvp_ssh.public_key_openssh
  file_permission = "0644"
}
resource "local_file" "cvp_ssh_private" {
  filename        = "${path.module}/dynamic/${random_id.prefix.hex}-cvp-id_rsa.pem"
  content         = tls_private_key.cvp_ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "cvp_config" {
  count    = var.vm_ssh_key != null ? 1 : 0
  content  = templatefile("${path.module}/templates/cvp-config.tpl", {
    cv_wifi_ha_cluster_ip      = local.cvp_wifi_cluster_ip,
    cvp_cluster_interface      = data.external.cluster_node_data[0].result.cvp_net_interface,
    cvp_ingest_key             = var.cvp_ingest_key,
    cvp_k8s_cluster_network    = local.cvp_k8s_cluster_network,
    cvp_major_version          = tonumber(split(".", var.cvp_version)[0]),
    cvp_cluster_nodes_number   = length(data.google_compute_instance.cluster_node[*]),
    cvp_ntp                    = local.cvp_ntp,
    cvp_size                   = local.cvp_suggested_size,
    cvp_wifi_enabled           = local.cvp_suggested_size == "prod_wifi" ? "yes" : "no",
    cvp_node1_device_interface = data.external.cluster_node_data[0].result.cvp_net_interface,
    cvp_node1_dns              = data.external.cluster_node_data[0].result.cvp_dns,
    cvp_node1_hostname         = data.external.cluster_node_data[0].result.cvp_hostname,
    cvp_node1_ip               = data.external.cluster_node_data[0].result.cvp_ip,
    cvp_node1_netmask          = cidrnetmask(data.google_compute_subnetwork.cluster_node.ip_cidr_range),
    cvp_node1_default_route    = data.external.cluster_node_data[0].result.cvp_default_route,
    cvp_node2_device_interface = length(data.google_compute_instance.cluster_node[*]) > 1 ? data.external.cluster_node_data[1].result.cvp_net_interface : null,
    cvp_node2_dns              = length(data.google_compute_instance.cluster_node[*]) > 1 ? data.external.cluster_node_data[1].result.cvp_dns : null,
    cvp_node2_hostname         = length(data.google_compute_instance.cluster_node[*]) > 1 ? data.external.cluster_node_data[1].result.cvp_hostname : null,
    cvp_node2_ip               = length(data.google_compute_instance.cluster_node[*]) > 1 ? data.external.cluster_node_data[1].result.cvp_ip : null,
    cvp_node2_netmask          = length(data.google_compute_instance.cluster_node[*]) > 1 ? cidrnetmask(data.google_compute_subnetwork.cluster_node.ip_cidr_range) : null,
    cvp_node2_default_route    = length(data.google_compute_instance.cluster_node[*]) > 1 ? data.external.cluster_node_data[1].result.cvp_default_route : null,
    cvp_node3_device_interface = length(data.google_compute_instance.cluster_node[*]) > 2 ? data.external.cluster_node_data[2].result.cvp_net_interface : null,
    cvp_node3_dns              = length(data.google_compute_instance.cluster_node[*]) > 2 ? data.external.cluster_node_data[2].result.cvp_dns : null,
    cvp_node3_hostname         = length(data.google_compute_instance.cluster_node[*]) > 2 ? data.external.cluster_node_data[2].result.cvp_hostname : null,
    cvp_node3_ip               = length(data.google_compute_instance.cluster_node[*]) > 2 ? data.external.cluster_node_data[2].result.cvp_ip : null,
    cvp_node3_netmask          = length(data.google_compute_instance.cluster_node[*]) > 2 ? cidrnetmask(data.google_compute_subnetwork.cluster_node.ip_cidr_range) : null,
    cvp_node3_default_route    = length(data.google_compute_instance.cluster_node[*]) > 2 ? data.external.cluster_node_data[2].result.cvp_default_route : null,
  })
  filename = "${path.module}/dynamic/${random_id.prefix.hex}-cvp-config.yml"
}

# TODO: Use proper user and key (needs fixing the image)
resource "null_resource" "cluster_node_user" {
  count = var.vm_ssh_key != null ? length(data.google_compute_instance.cluster_node[*].network_interface.0.access_config.0.nat_ip) : 0

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install python3",
      "id -u ${var.vm_admin_user} &>/dev/null || sudo useradd -m ${var.vm_admin_user} && sudo mkdir -p /home/${var.vm_admin_user}/.ssh && echo \"${var.vm_ssh_key}\" |sudo tee /home/${var.vm_admin_user}/.ssh/authorized_keys && sudo chown -R ${var.vm_admin_user}: /home/${var.vm_admin_user} && sudo echo \"${var.vm_admin_user} ALL=(ALL:ALL) NOPASSWD:ALL\" > /etc/sudoers.d/cvp-sudoers"
      #"echo ${random_password.root.result}|sudo passwd --stdin root"
    ]

    connection {
      host        = data.google_compute_instance.cluster_node[count.index].network_interface.0.access_config.0.nat_ip
      #type        = "ssh"
      user        = "root" #var.vm_admin_user
      #private_key = var.vm_private_ssh_key
      password    = "arastra"
    }
  }
}
resource "null_resource" "cluster_node_ansible" {
  count = var.vm_ssh_key != null ? length(data.google_compute_instance.cluster_node[*].network_interface.0.access_config.0.nat_ip) : 0
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${data.google_compute_instance.cluster_node[count.index].network_interface.0.access_config.0.nat_ip}, -u ${var.vm_admin_user} --private-key ${var.vm_private_ssh_key_path} --extra-vars \"cvp_version=${var.cvp_version} api_token=${var.cvp_download_token} cvp_size=${local.cvp_suggested_size} cvp_enable_advanced_login_options=${var.cvp_enable_advanced_login_options} node_name=node${(count.index+1)} cvp_config=${abspath(local_file.cvp_config[0].filename)} cvp_authorized_keys=${abspath(local_file.cvp_ssh_authorized_keys.filename)} cvp_private_key=${abspath(local_file.cvp_ssh_private.filename)}\" ansible/cvp-provision.yaml"
  }

  depends_on = [
    local_file.cvp_config
  ]
}

# data "external" "cvp_token" {
#   program = [ 
#   "ssh",
#   "-tt",
#     "-o UserKnownHostsFile=/dev/null",
#     "-o StrictHostKeyChecking=no",
#   "${var.vm_admin_user}@${data.google_compute_instance.cluster_node[0].network_interface.0.access_config.0.nat_ip}", "curl -sd '{\"reenrollDevices\":[\"*\"]}' -k https://127.0.0.1:9911/cert/createtoken" ]

#   depends_on = [
#     null_resource.cluster_node_user
#   ]
# }