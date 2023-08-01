terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "3.0.2"
    }
  }
  required_version = "~> 1.3"
}

provider "rancher2" {
  api_url    = var.rancher2.url
  access_key = var.rancher2.access_key
  secret_key = var.rancher2.secret_key
}
