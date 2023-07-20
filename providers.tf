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
    kubernetes = {
      version = "2.22.0"
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
  kubeconfig = local.harvester_kubeconfig_path
}

provider "rancher2" {
  api_url    = var.rancher2.url
  access_key = var.rancher2.access_key
  secret_key = var.rancher2.secret_key
}

provider "kubernetes" {
  config_path    = local.harvester_kubeconfig_path
}