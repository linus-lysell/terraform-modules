terraform {}

provider "azurerm" {
  features {}
}

provider "azuread" {}

provider "random" {}

module "aks" {
  source = "../../../modules/azure/aks"

  providers = {
    azurerm = azurerm
  }

  environment                   = "dev"
  location_short                = "we"
  name                          = "xks"
  core_name                     = "core"
  unique_suffix                 = 1337
  aks_name_suffix               = "1"
  aks_managed_identity_group_id = "1337"
  azure_metrics_identity = {
    id           = "id"
    principal_id = "pid"
  }

  aks_config = {
    version                  = "1.24.3"
    production_grade         = false
    priority_expander_config = { "10" : [".*standard.*"], "20" : [".*spot.*"] }
    default_node_pool = {
      node_labels = {
        "test" = "test"
      }
    }
    node_pools = [
      {
        name      = "pool1"
        version   = "1.24.3"
        vm_size   = "Standard_B2s"
        min_count = 1
        max_count = 1
        node_taints = [
          "test"
        ]
        node_labels = {
          "test" = "test"
        }
        spot_enabled   = false
        spot_max_price = null
      }
    ]
  }
  namespaces = [
    {
      name                    = "team1"
      delegate_resource_group = true
      labels = {
        "test" = "test"
      }
      flux = {
        enabled = true
        repo    = "repo"
      }
    }
  ]
  aks_public_ip_prefix_id = "id"
  aks_authorized_ips      = ["0.0.0.0/0"]
  ssh_public_key          = "key"

  aad_groups = {
    view = {
      test = {
        id   = "id"
        name = "name"
      }
    }
    edit = {
      test = {
        id   = "id"
        name = "name"
      }
    }
    cluster_admin = {
      id   = "id"
      name = "name"
    }
    cluster_view = {
      id   = "id"
      name = "name"
    }
    aks_managed_identity = {
      id   = "id"
      name = "name"
    }
  }

  log_eventhub_name                  = "eventhub1"
  log_eventhub_authorization_rule_id = "12345"
}
