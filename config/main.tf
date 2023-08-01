data "rancher2_cluster_v2" "harvester" {
  name = var.harvester_cluster_name
}

resource "local_file" "harvester_kube_config" {
  content  = data.rancher2_cluster_v2.harvester.kube_config
  filename = "${path.module}/harvester.kubeconfig"
}
