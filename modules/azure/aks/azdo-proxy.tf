data "azurerm_key_vault_secret" "azdo_proxy_pat" {
  name         = "azure-devops-pat"
  key_vault_id = data.azurerm_key_vault.core.id
}

resource "random_password" "azdo_proxy" {
  for_each = {
    for ns in var.namespaces :
    ns.name => ns
  }

  length  = 48
  special = false

  keepers = {
    namespace = each.key
  }
}

locals {
  azdo_proxy_json = {
    domain       = "dev.azure.com"
    pat          = data.azurerm_key_vault_secret.azdo_proxy_pat.value
    organization = var.azure_devops_organization
    repositories = [
      for ns in var.namespaces : {
        project = ns.flux.azdo_project
        name    = ns.flux.azdo_repo
        token   = random_password.azdo_proxy[ns.name].result
      }
    ]
  }
}

resource "kubernetes_namespace" "azdo_proxy" {
  metadata {
    labels = {
      name = "azdo-proxy"
    }
    name = "azdo-proxy"
  }
}

resource "kubernetes_secret" "azdo_proxy" {
  metadata {
    name      = "azdo-proxy-config"
    namespace = kubernetes_namespace.azdo_proxy.metadata[0].name
  }

  data = {
    "config.json" = jsonencode(local.azdo_proxy_json)
  }
}

resource "helm_release" "azdo_proxy" {
  repository = "https://xenitab.github.io/azdo-proxy/"
  chart      = "azdo-proxy"
  version    = "v0.1.0-rc5"
  name       = kubernetes_namespace.azdo_proxy.metadata[0].name
  namespace  = kubernetes_namespace.azdo_proxy.metadata[0].name

  set {
    name  = "configSecretName"
    value = kubernetes_secret.azdo_proxy.metadata[0].name
  }
}
