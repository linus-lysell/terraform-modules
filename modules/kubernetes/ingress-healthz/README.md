# Ingress Healthz (ingress-healthz)

This module is used to deploy a very simple NGINX server meant to check the health of cluster ingress.
It is meant to simulate an application that expects traffic through the ingress controller with
automatic DNS creation and certificate creation, without depending on the stability of a dynamic application.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.6.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.ingress_healthz](https://registry.terraform.io/providers/hashicorp/helm/2.6.0/docs/resources/release) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/2.13.1/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | DNS Zone to create ingress sub domain under | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment ingress-healthz is deployed in | `string` | n/a | yes |
| <a name="input_linkerd_enabled"></a> [linkerd\_enabled](#input\_linkerd\_enabled) | Should linkerd be enabled | `bool` | `false` | no |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Region short name | `string` | `""` | no |
| <a name="input_public_private_enabled"></a> [public\_private\_enabled](#input\_public\_private\_enabled) | Should ingress controllers for both public and private be enabled? | `bool` | `false` | no |

## Outputs

No outputs.
