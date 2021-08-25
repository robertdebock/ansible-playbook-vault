locals {
  # A map from "size" (a Terraform variable) to the name if the Digital Ocean
  # [droplet size](https://slugs.do-api.dev/). The variable "size" is based on HashiCorps
  # [reference architecture](https://learn.hashicorp.com/tutorials/vault/reference-architecture).

  _do_size = {
    small = "g-2vcpu-8gb"
    large = "m-8vcpu-64gb"
  }

  do_size = local._do_size[var.size]
}
