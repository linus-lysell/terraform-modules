variable "location_short" {
  description = "The Azure region short name"
  type        = string
}

variable "environment" {
  description = "The environment name to use for the deploy"
  type        = string
}

variable "name" {
  description = "The commonName to use for the deploy"
  type        = string
}

variable "unique_suffix" {
  description = "Unique suffix that is used in globally unique resources names"
  type        = string
}

variable "core_name" {
  description = "The commonName for the core infrastructure"
  type        = string
}

variable "aks_name_suffix" {
  description = "The suffix for the Azure Kubernetes Service (AKS) clusters"
  type        = number
}

variable "aks_default_node_pool_vm_size" {
  description = "The VM size of the AKS clusters default node pool. Do not override unless explicitly required."
  type        = string
  default     = "Standard_D2ds_v5"
}

variable "aks_config" {
  description = "The Azure Kubernetes Service (AKS) configuration"
  type = object({
    version = string
    # Enables paid SKU for AKS and makes the default node pool HA
    production_grade = bool
    # Will replace the default cluster auto scaler expander with a priority expander, 
    # see https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/expander/priority/readme.md#configuration
    priority_expander_config = optional(map(list(string)))
    node_pools = list(object({
      name           = string
      version        = string
      vm_size        = string
      min_count      = number
      max_count      = number
      spot_enabled   = bool
      spot_max_price = number
      node_taints    = list(string)
      node_labels    = map(string)
    }))
  })

  validation {
    condition = alltrue([
      for np in concat(var.aks_config.node_pools, [{ version : var.aks_config.version }]) : can(regex("^1.(23|24|25)", np.version))
    ])
    error_message = "The Kubernetes version has not been validated yet, supported versions are 1.23, 1.24, 1.25."
  }

  validation {
    condition = alltrue([
      for np in var.aks_config.node_pools : split(".", np.version)[1] <= split(".", var.aks_config.version)[1]
    ])
    error_message = "The node Kubernetes version should not be newer than the cluster version, upgrade the cluster first."
  }

  validation {
    condition = alltrue([
      for np in var.aks_config.node_pools : length(np.name) <= 12
    ])
    error_message = "The name value cannot be longer than 12 characters."
  }

  validation {
    condition = alltrue([
      for np in var.aks_config.node_pools : can(regex("^[a-z0-9]+$", np.name))
    ])
    error_message = "The name value has to be lowercase alphanumeric."
  }

  validation {
    condition = alltrue([
      for np in var.aks_config.node_pools : can(regex("^[a-z]", np.name))
    ])
    error_message = "The name value has to begin with a lowercase letter."
  }

  validation {
    condition = alltrue([
      for np in var.aks_config.node_pools : can(regex("[12]$", np.name))
    ])
    error_message = "The name value should end with a 1 or 2 to enable blue green pool creation."
  }

  # Spot max price is set when spot is enabled
  validation {
    condition = alltrue([
      for np in var.aks_config.node_pools : (!np.spot_enabled && np.spot_max_price == null) || (np.spot_enabled && np.spot_max_price != null)
    ])
    error_message = "The spot_max_price cannot be null when spot_enabled is true."
  }
}

variable "ssh_public_key" {
  description = "SSH public key to add to servers"
  type        = string
}

variable "aks_authorized_ips" {
  description = "Authorized IPs to access AKS API"
  type        = list(string)
}

variable "aks_public_ip_prefix_id" {
  description = "Public IP ID AKS egresses from"
  type        = string
}

variable "aad_groups" {
  description = "Configuration for Azure AD Groups (AAD Groups)"
  type = object({
    view = map(any)
    edit = map(any)
    cluster_admin = object({
      id   = string
      name = string
    })
    cluster_view = object({
      id   = string
      name = string
    })
    aks_managed_identity = object({
      id   = string
      name = string
    })
  })
}

variable "namespaces" {
  description = "The namespaces that should be created in Kubernetes"
  type = list(
    object({
      name                    = string
      delegate_resource_group = bool
    })
  )
}

variable "aks_managed_identity_group_id" {
  description = "The group id of aks managed identity"
  type        = string
}

variable "azure_metrics_identity" {
  description = "MSI authentication identity for Azure Metrics"
  type = object({
    id           = string
    principal_id = string
  })
}

variable "aks_audit_log_retention" {
  description = "The aks audit log retention in days, 0 = infinite"
  type        = number
  default     = 365
}

variable "log_eventhub_name" {
  description = "The eventhub name for k8s logs"
  type        = string
}

variable "log_eventhub_authorization_rule_id" {
  description = "The authoritzation rule id for event hub"
  type        = string
}
