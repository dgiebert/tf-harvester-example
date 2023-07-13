# For better readability
locals {
  harvester_kube_config = var.harvester_kube_config != "" ? var.harvester_kube_config : "${path.root}/harvester.kubeconfig"
}
