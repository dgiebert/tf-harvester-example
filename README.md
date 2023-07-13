# Harvester + k3s Provisioner using Rancher

<!-- BEGIN_TF_DOCS -->

## Usage

1. Get the Harvester kubeconfig and place it in `harvester.kubeconfig`
1. Adapt the config
1. Configure Harvester with `terraform apply`


#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.3 |
| <a name="requirement_harvester"></a> [harvester](#requirement_harvester) | 0.6.2 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement_rancher2) | 3.0.2 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_cluster_networks"></a> [cluster_networks](#input_cluster_networks) | The name for the cluster network | <pre>object({<br>    nics        = list(string)<br>    mtu         = optional(number)<br>    bond_mode   = optional(string)<br>    bond_miimon = optional(number)<br><br>  })</pre> |
| <a name="input_cluster_vlans"></a> [cluster_vlans](#input_cluster_vlans) | n/a | <pre>map(object({<br>    vlans = list(number)<br>  }))</pre> |
| <a name="input_harvester_cluster_name"></a> [harvester_cluster_name](#input_harvester_cluster_name) | The name shown in the UI, needed for interaction via the Rancher UI | `string` |
| <a name="input_harvester_kube_config"></a> [harvester_kube_config](#input_harvester_kube_config) | The location to check for the kubeconfig to connect to Harverster | `string` |
| <a name="input_images"></a> [images](#input_images) | The name for the cluster network | <pre>map(object({<br>    url       = string<br>    name      = optional(string)<br>    namespace = optional(string)<br>  }))</pre> |
| <a name="input_rancher2"></a> [rancher2](#input_rancher2) | Connection details for the Rancher2 API | <pre>object({<br>    access_key = string,<br>    secret_key = string,<br>    url        = string<br>  })</pre> |
| <a name="input_teams"></a> [teams](#input_teams) | n/a | <pre>map(object({<br>    limits = object({<br>      project = object({<br>        cpu              = string<br>        memory           = string<br>        requests_storage = string<br>      })<br>      namespace = object({<br>        cpu              = string<br>        memory           = string<br>        requests_storage = string<br>    }) })<br>    members = list(string)<br>    additional_namespace = optional(map(object({<br>      limits = object({<br>        cpu              = string<br>        memory           = string<br>        requests_storage = string<br>      })<br>    })))<br>  }))</pre> |

#### Outputs

No outputs.
<!-- END_TF_DOCS -->
