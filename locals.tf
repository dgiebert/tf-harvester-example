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
  registration_url = "curl -fL ${var.rancher2.url}/system-agent-install.sh | sudo  sh -s - --server ${var.rancher2.url} --token ${rancher2_cluster_v2.default.cluster_registration_token[0].token}"
}