locals {
  cloud_init = {
    network_data = ""
    user_data    = <<-EOF
      #cloud-config
      user: ${var.ssh_user}
      package_update: true
      package_upgrade: true
      packages:
        - qemu-guest-agent
      runcmd:
        - - systemctl
          - enable
          - '--now'
          - qemu-guest-agent
      ssh_authorized_keys:
        - >-
          ${join("\n    ", (values(harvester_ssh_key.keys))[*].public_key)}
      EOF
  }
  registration_url      = "curl -fL ${var.rancher2.url}/system-agent-install.sh | sudo  sh -s - --server ${var.rancher2.url} --token ${rancher2_cluster_v2.default.cluster_registration_token[0].token}"
  harvester_kube_config = var.harvester_kube_config != "" ? var.harvester_kube_config : "${path.root}/harvester.kubeconfig"
  server_vms = {
    number    = coalesce(var.server_vms.number, 3)
    cpu       = coalesce(var.server_vms.cpu, 2)
    memory    = coalesce(var.server_vms.memory, "4Gi")
    disk_size = coalesce(var.efi.server_vms.disk_size, "20Gi")
  }
  agent_vms = {
    number    = coalesce(var.agent_vms.number, 3)
    cpu       = coalesce(var.agent_vms.cpu, 2)
    memory    = coalesce(var.agent_vms.memory, "4Gi")
    disk_size = coalesce(var.efi.agent_vms.disk_size, "20Gi")
  }
}
