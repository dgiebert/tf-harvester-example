variable "harvester_kube_config" {
  description = "The location to check for the kubeconfig to connect to Harverster"
  type        = string
  default     = ""
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

variable "backup_config" {
  type = object({
    type         = string
    region       = string
    bucket       = string
    acces_key_id = string
    secret_key   = string
  })
  default = {
    type         = "s3"
    region       = "eu-central-1"
    bucket       = "bucket"
    acces_key_id = "blub"
    secret_key   = "blub2"
  }
}

variable "teams" {
  type = map(object({
    limits = object({
      limits_cpu       = string
      limits_memory    = string
      requests_storage = string
    })
    members = list(string)
  }))
  default = {
    "team1" = {
      limits = {
        limits_cpu       = "100m"
        limits_memory    = "100Mi"
        requests_storage = "1Gi"
      }
      members = ["test"]
    }
    "team2" = {
      limits = {
        limits_cpu       = "100m"
        limits_memory    = "100Mi"
        requests_storage = "1Gi"
      }
      members = ["test"]
    }
  }
}
