variable "harvester_kube_config" {
  description = "The location to check for the kubeconfig to connect to Harverster"
  type        = string
  default     = "config/harvester.kubeconfig"
}

variable "harvester_cluster_name" {
  description = "The name shown in the UI, needed for interaction via the Rancher UI"
  type        = string
  default     = "harvey"
}

variable "rancher2" {
  description = "Connection details for the Rancher2 API"
  type = object({
    access_key = string,
    secret_key = string,
    url        = string
  })
  validation {
    condition     = length(var.rancher2.access_key) > 0
    error_message = "Access Key must be provided check https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys"
  }
  validation {
    condition     = length(var.rancher2.secret_key) > 0
    error_message = "Secret Key must be provided check https://docs.ranchermanager.rancher.io/reference-guides/user-settings/api-keys"
  }
  validation {
    condition     = length(var.rancher2.url) > 0
    error_message = "Rancher URL must be provided"
  }
}

# How is the layout on the nodes?
variable "cluster_networks" {
  description = "The name for the cluster network"
  type = object({
    nics        = list(string)
    mtu         = optional(number)
    bond_mode   = optional(string)
    bond_miimon = optional(number)

  })
  default = {
    nics = ["enp38s0"]
  }
}
variable "cluster_vlans" {
  type = map(object({
    vlans = list(number)
  }))
  default = {
    # For all developers
    "harvester-public" = {
      vlans = [2]
    }
    # VLAN for specific projects
    "suma" = {
      vlans = [3]
    }
  }
}

variable "images" {
  description = "The name for the cluster network"
  type = map(object({
    url       = string
    name      = optional(string)
    namespace = optional(string)
  }))
  default = {
    "opensuse154" = {
      name = "openSUSE-Leap-15.4.x86_64-NoCloud.qcow2"
      url  = "https://downloadcontent-us1.opensuse.org/repositories/Cloud:/Images:/Leap_15.4/images/openSUSE-Leap-15.4.x86_64-NoCloud.qcow2"
    }
  }
}

variable "settings" {
  description = "Settings to be applied to Harvester"
  # type = map()
  default = {
    overcommit-config = {
      "cpu" : 200,
      "memory" : 100,
      "storage" : 100
    }
    # auto-disk-provision-paths = "/dev/sd*"
    #backup-target = {
    #  "type" : "s3",
    #  "endpoint" : "https://s3.endpoint.svc",
    #  "accessKeyId" : "test-access-key-id",
    #  "secretAccessKey" : "test-access-key",
    #  "bucketName" : "test-bup",
    #  "bucketRegion" : "us‑east‑2",
    #  "cert" : "",
    #  "virtualHostedStyle" : false
    #}
  }
}

variable "managed_charts" {
  description = "Settings to be applied to Harvester"
  default = {
    rancher-monitoring = [
      {
        spec = {
          values = {
            alertmanager = {
              alertmanagerSpec = {
                externalUrl = "https://10.7.101.195/api/v1/namespaces/cattle-monitoring-system/services/http:rancher-monitoring-alertmanager:9093/proxy/"
              }
            }
          }
        }
      },
      {
        spec = {
          values = {
            prometheus = {
              prometheusSpec = {
                externalUrl = "https://10.7.101.195/api/v1/namespaces/cattle-monitoring-system/services/http:rancher-monitoring-alertmanager:9093/proxy/"
              }
            }
          }
        }
      }
    ]
  }
}

variable "project_limits" {
  default = {
    cpu              = "16000m"
    memory           = "16000Mi"
    requests_storage = "1000Gi"
  }
}

variable "ad_group_search_base" {
  default = ""
}
variable "teams" {
  # type = map(object({
  #   limits = optional(object({
  #     project = object({
  #       cpu              = string
  #       memory           = string
  #       requests_storage = string
  #     })
  #     namespace = object({
  #       cpu              = string
  #       memory           = string
  #       requests_storage = string
  #   }) }))
  #   members = string
  #   additional_namespace = optional(map(object({
  #     limits = object({
  #       cpu              = string
  #       memory           = string
  #       requests_storage = string
  #     })
  #   })))
  # }))
  default = {
    "team1" = {
      group = ["fffffff-ffff-ffff-ffff-fffffffffff"]
      limits = {
        project = {
          cpu              = "2000m"
          memory           = "2000Mi"
          requests_storage = "2Gi"
        }
        namespace = {
          cpu              = "1500m"
          memory           = "1500Mi"
          requests_storage = "1Gi"
        }
      }
      additional_namespace = {
        "service" = {
          limits = {
            cpu              = "500m"
            memory           = "500Mi"
            requests_storage = "1Gi"
          }
        }
      }
    }
  }
}
