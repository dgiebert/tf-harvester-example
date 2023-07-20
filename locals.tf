# For better readability
locals {
  harvester_kubeconfig_path = var.harvester_kube_config != "" ? var.harvester_kube_config : "${path.root}/harvester.kubeconfig"
}
