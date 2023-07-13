terraform {
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = "0.6.2"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.0.2"
    }
  }
  required_version = "~> 1.3"
}

# Some day ...
#resource "local_file" "harvester_kube_config" {
#  content  = data.rancher2_cluster_v2.harvester.kube_config
#  filename = "${path.module}/harvester.kubeconfig"
#}
provider "harvester" {
  kubeconfig = var.harvester_kube_config != "" ? var.harvester_kube_config : "${path.root}/harvester.kubeconfig"
}

provider "rancher2" {
  api_url    = var.rancher2.url
  access_key = var.rancher2.access_key
  secret_key = var.rancher2.secret_key
}