/**
  * # Reloader
  *
  * Adds [`Reloader`](https://github.com/stakater/Reloader) to a Kubernetes clusters.
  *
  */

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.6.0"
    }
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    labels = {
      name                = "reloader"
      "xkf.xenit.io/kind" = "platform"
    }
    name = "reloader"
  }
}

resource "helm_release" "reloader" {
  repository  = "https://stakater.github.io/stakater-charts"
  chart       = "reloader"
  name        = "reloader"
  namespace   = kubernetes_namespace.this.metadata[0].name
  version     = "v0.0.102"
  max_history = 3

  set {
    name  = "reloader.deployment.priorityClassName"
    value = "platform-low"
  }
  set {
    name  = "reloader.deployment.resources.requests.cpu"
    value = "15m"
  }
  set {
    name  = "reloader.deployment.resources.requests.memory"
    value = "50Mi"
  }
}
