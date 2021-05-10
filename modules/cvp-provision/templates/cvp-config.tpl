common:
  aeris_ingest_key: ${cvp_ingest_key}
  cluster_interface: ${cvp_cluster_interface}
  cv_wifi_enabled: '${cvp_wifi_enabled}'
  cv_wifi_ha_cluster_ip: ${cv_wifi_ha_cluster_ip}
  %{if cvp_major_version >= 2021}kube_cluster_network: ${cvp_k8s_cluster_network}%{endif}
  ntp:
  - ${cvp_ntp}
node1:
  default_route: ${cvp_node1_default_route}
  dns: 
  - ${cvp_node1_dns}
  hostname: ${cvp_node1_hostname}
  device_interface: ${cvp_node1_device_interface}
  interfaces:
    ${cvp_node1_device_interface}:
      ip_address: ${cvp_node1_ip}
      netmask: ${cvp_node1_netmask}
%{if cvp_cluster_nodes_number == 3}
  num_static_route: '2'
  static_routes:
  - interface: ${cvp_node1_device_interface}
    nexthop: ${cvp_node1_default_route}
    route: ${cvp_node2_ip}/32
  - interface: ${cvp_node1_device_interface}
    nexthop: ${cvp_node1_default_route}
    route: ${cvp_node3_ip}/32
%{endif}
%{if cvp_cluster_nodes_number > 1}
node2:
  default_route: ${cvp_node2_default_route}
  dns: 
  - ${cvp_node2_dns}
  hostname: ${cvp_node2_hostname}
  device_interface: ${cvp_node2_device_interface}
  interfaces:
    ${cvp_node2_device_interface}:
      ip_address: ${cvp_node2_ip}
      netmask: ${cvp_node2_netmask}
  num_static_route: '2'
  static_routes:
  - interface: ${cvp_node2_device_interface}
    nexthop: ${cvp_node2_default_route}
    route: ${cvp_node1_ip}/32
  - interface: ${cvp_node2_device_interface}
    nexthop: ${cvp_node2_default_route}
    route: ${cvp_node3_ip}/32
%{endif}%{if cvp_cluster_nodes_number > 2}
node3:
  default_route: ${cvp_node3_default_route}
  dns: 
  - ${cvp_node3_dns}
  hostname: ${cvp_node3_hostname}
  device_interface: ${cvp_node3_device_interface}
  interfaces:
    ${cvp_node3_device_interface}:
      ip_address: ${cvp_node3_ip}
      netmask: ${cvp_node3_netmask}
  num_static_route: '2'
  static_routes:
  - interface: ${cvp_node3_device_interface}
    nexthop: ${cvp_node3_default_route}
    route: ${cvp_node1_ip}/32
  - interface: ${cvp_node3_device_interface}
    nexthop: ${cvp_node3_default_route}
    route: ${cvp_node2_ip}/32
%{endif}
version: 2
