# Operating System Image (OpenSuse Leap)
resource "harvester_image" "opensuse-leap-15_4" {
  name         = "opensuse-leap-15.4"
  namespace    = var.namespace
  description  = "openSUSE Leap 15.4 NoCloud x86_64"
  display_name = "openSUSE Leap 15.4"
  source_type  = "download"
  url          = "https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.4/images/openSUSE-Leap-15.4.x86_64-NoCloud.qcow2"
}

# VLAN Network
resource "harvester_network" "vlan" {
  name        = "vlan-${var.cluster.name}-${var.vlan_id}"
  namespace   = var.namespace
  description = "VLAN used for the cluster ${var.cluster.name} with ID ${var.vlan_id}"

  vlan_id = var.vlan_id

  route_mode = "auto"

  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}

# SSH Keys created using a for loop over the var.ssh_keys map
resource "harvester_ssh_key" "keys" {
  for_each = var.ssh_keys

  name        = each.key
  description = "SSH Key for ${each.key}"
  namespace   = var.namespace
  public_key  = each.value
}

# Harvester VMs created to serve as server nodes (configured via var.server_vms)
resource "harvester_virtualmachine" "servers" {
  count       = var.server_vms.number
  name        = "${var.cluster.name}-server-${count.index}"
  description = "This server node belongs to the cluster ${var.cluster.name} running ${harvester_image.opensuse-leap-15_4.display_name}"
  namespace   = var.namespace
  cpu         = var.server_vms.cpu
  memory      = var.server_vms.memory
  efi         = var.efi

  tags = {
    cluster = var.cluster.name
    image   = harvester_image.opensuse-leap-15_4.name
    role    = "server"
  }

  network_interface {
    name         = "nic-1"
    network_name = harvester_network.vlan.id
  }

  disk {
    name        = "root"
    size        = var.server_vms.disk_size
    image       = harvester_image.opensuse-leap-15_4.id
    auto_delete = true
  }

  cloudinit {
    user_data    = local.cloud_init.user_data
    network_data = local.cloud_init.network_data
  }
  # This is to ignore volumes added using the CSI Provider
  lifecycle {
    ignore_changes = [
      disk,
    ]
  }
}

# Harvester VMs created to serve as agent nodes (configured via var.agent_vms)
resource "harvester_virtualmachine" "agents" {
  count       = var.agent_vms.number
  name        = "${var.cluster.name}-agent-${count.index}"
  description = "This server node belongs to the cluster ${var.cluster.name} running ${harvester_image.opensuse-leap-15_4.display_name}"
  namespace   = var.namespace
  cpu         = var.agent_vms.cpu
  memory      = var.agent_vms.memory
  efi         = var.efi

  tags = {
    cluster = var.cluster.name
    image   = harvester_image.opensuse-leap-15_4.name
    role    = "agent"
  }

  network_interface {
    name         = "nic-1"
    network_name = harvester_network.vlan.id
  }

  disk {
    name  = "root"
    size  = var.agent_vms.disk_size
    image = harvester_image.opensuse-leap-15_4.id
  }

  cloudinit {
    user_data    = local.cloud_init.user_data
    network_data = local.cloud_init.network_data
  }
}

# Create a K3S Cluster
resource "rancher2_cluster_v2" "default" {
  name                  = var.cluster.name
  kubernetes_version    = var.cluster.k3s_version
  enable_network_policy = true # Experimental
}

# Execute the cluster registration command on the servers (passing the needed flags)
resource "ssh_resource" "init-servers" {
  for_each = { for machine in harvester_virtualmachine.servers : machine.network_interface[0].ip_address => machine }

  host        = each.key
  user        = var.ssh_user
  private_key = file(var.ssh_key_location)

  pre_commands = [
    "sudo mkdir -p /etc/rancher/k3s",
    "sudo chmod 777 /etc/rancher/k3s",
    "sudo chmod 777 /etc/sysctl.d/"
  ]

  file {
    destination = "/etc/sysctl.d/90-kubelet.conf"
    source      = "${path.root}/hardening/90-kubelet.conf"
  }
  file {
    destination = "/etc/rancher/k3s/config.yaml"
    source      = "${path.root}/hardening/k3s-config.yaml"
  }

  commands = [
    "sudo sysctl -p /etc/sysctl.d/90-kubelet.conf",
    "sudo chmod 755 /etc/rancher/k3s",
    "sudo chmod 755 /etc/sysctl.d/",
    "sudo chown root:root /etc/rancher/k3s/config.yaml",
    "sudo chown root:root /etc/sysctl.d/90-kubelet.conf",
    "${local.registration_url} ${var.rancher2.server_args}"
  ]
}

# # Execute the cluster registration command on the agents
# resource "ssh_resource" "init-agents" {
#   for_each = { for machine in harvester_virtualmachine.agents : machine.network_interface[0].ip_address => machine }

#   host        = each.key
#   user        = var.ssh_user
#   private_key = file(var.ssh_key_location)

#   commands = [
#     "${rancher2_cluster_v2.default.cluster_registration_token[0].node_command}"
#   ]
# }
