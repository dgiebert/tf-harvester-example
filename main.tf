resource "harvester_clusternetwork" "vlans" {
  name = "vlans"
}

resource "harvester_vlanconfig" "config" {
  name = "config"

  uplink {
    nics        = var.cluster_networks.nics
    bond_mode   = coalesce(var.cluster_networks.bond_mode, "active-backup")
    mtu         = coalesce(var.cluster_networks.mtu, 1500)
    bond_miimon = coalesce(var.cluster_networks.bond_miimon, 0)
  }

  cluster_network_name = harvester_clusternetwork.vlans.name
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      uplink[0].bond_miimon
    ]
  }
}

resource "harvester_network" "vlan" {
  for_each = { for o in flatten([
    for index, net in var.cluster_vlans : [
      for vlan in net.vlans : {
        vlan_id   = vlan
        namespace = index
      }
  ]]) : o.vlan_id => o }

  name       = "vlan-${each.key}"
  namespace  = coalesce(each.value.namespace, "harvester-public")
  vlan_id    = each.key
  route_mode = "auto"

  cluster_network_name = harvester_clusternetwork.vlans.name
}

resource "harvester_image" "os" {
  for_each  = var.images
  name      = each.key
  namespace = coalesce(each.value.namespace, "harvester-public")

  display_name = coalesce(each.value.name, each.key)
  source_type  = "download"
  url          = each.value.url
}

data "rancher2_cluster" "harvester" {
  name = var.harvester_cluster_name
}

## Ugly hack: https://github.com/hashicorp/terraform-provider-kubernetes/issues/723
resource "null_resource" "settings" {
  for_each = var.settings
  triggers = {
    kubeconfig = local.harvester_kubeconfig_path
    key        = each.key
    value      = replace(jsonencode(each.value), "\"", "\\\"")
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
     kubectl patch --type merge settings ${self.triggers.key} -p '{"value": "${self.triggers.value}"}' --kubeconfig ${self.triggers.kubeconfig}
   EOT
  }
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
     kubectl patch --type merge settings ${self.triggers.key} -p '{"value": ""}' --kubeconfig ${self.triggers.kubeconfig}
   EOT
  }
}

resource "null_resource" "managed_charts" {
  for_each = { for o in flatten([
    for index, patches in var.managed_charts : [
      for patch in patches : {
        patch = patch
        chart = index
      }
  ]]) : "${o.chart}-${sha256(patch)}" => o }

  triggers = {
    kubeconfig = local.harvester_kubeconfig_path
    key        = each.value.chart
    value      = replace(jsonencode(each.value.patch), "\"", "\\\"")
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
     kubectl patch -n fleet-local --type merge managedchart ${self.triggers.key} -p ${self.triggers.value} --kubeconfig ${self.triggers.kubeconfig}
   EOT
  }
}

resource "rancher2_project" "teams" {
  for_each = var.teams

  name       = each.key
  cluster_id = data.rancher2_cluster.harvester.id
  resource_quota {
    project_limit {
      limits_cpu       = var.project_limits.cpu              #coalesce(each.value.limits.project.cpu, var.project_limits.cpu)
      limits_memory    = var.project_limits.memory           # coalesce(each.value.limits.project.memory, var.project_limits.memory)
      requests_storage = var.project_limits.requests_storage # coalesce(each.value.limits.project.requests_storage, var.project_limits.requests_storage)
    }
    namespace_default_limit {
      limits_cpu       = var.project_limits.cpu              # coalesce(each.value.limits.namespace.cpu, var.project_limits.cpu)
      limits_memory    = var.project_limits.memory           # coalesce(each.value.limits.namespace.memory, var.project_limits.memory)
      requests_storage = var.project_limits.requests_storage # coalesce(each.value.limits.namespace.requests_storage, var.project_limits.requests_storage)
    }
  }
}

resource "rancher2_namespace" "team" {
  for_each = var.teams
  # Per Team member namespaces
  # { for o in flatten([
  #   for index, team in var.teams : [
  #     for member in team.members : {
  #       member = member
  #       team   = index
  #     }
  # ]]) : o.team => o }

  name        = each.key
  project_id  = rancher2_project.teams[each.key].id
  description = "${each.key}'s default namespace for project"

  # resource_quota {
  #   limit {
  #     limits_cpu       = each.value.limits.namespace.cpu
  #     limits_memory    = each.value.limits.namespace.memory
  #     requests_storage = each.value.limits.namespace.requests_storage
  #   }
  # }
}

# resource "rancher2_namespace" "services" {
#   for_each = coalesce(one([for index, team in var.teams : { for ns, limits in team.additional_namespace : "${index}-${ns}" => limits }]), {})

#   name       = each.key
#   project_id = rancher2_project.teams[element(split("-", each.key), 0)].id
#   resource_quota {
#     limit {
#       limits_cpu       = each.value.limits.cpu
#       limits_memory    = each.value.limits.memory
#       requests_storage = each.value.limits.requests_storage
#     }
#   }
# }


data "rancher2_role_template" "project-member" {
  name = "Project Member"
}

resource "rancher2_project_role_template_binding" "members" {
  for_each = { for o in flatten([
    for index, team in var.teams : [
      for group in team.groups : {
        group = group
        team  = index
      }
  ]]) : o.team => o }

  name               = "${rancher2_project.teams[each.key].name}-${each.value.group}"
  project_id         = rancher2_project.teams[each.key].id
  role_template_id   = data.rancher2_role_template.project-member.id
  group_principal_id = "azuread_group://${each.value.group}"
}
