resource "digitalocean_ssh_key" "vault" {
  name       = "vault"
  public_key = file("${path.module}/files/id_rsa.pub")
}

# Create a new Droplet using the SSH key
resource "digitalocean_droplet" "vault_a" {
  count     = var.amount
  image     = "fedora-34-x64"
  name      = "vault-a-${count.index}.meinit.nl"
  region    = "ams3"
  size      = local.do_size
  ssh_keys  = [digitalocean_ssh_key.vault.fingerprint]
}

resource "digitalocean_droplet" "vault_b" {
  count     = var.amount
  image     = "fedora-34-x64"
  name      = "vault-b-${count.index}.meinit.nl"
  region    = "ams3"
  size      = local.do_size
  ssh_keys  = [digitalocean_ssh_key.vault.fingerprint]
}

resource "digitalocean_droplet" "loadbalancer_a" {
  count     = var.loadbalancers
  image     = "fedora-34-x64"
  name      = "loadbalancer-a-${count.index}.meinit.nl"
  region    = "ams3"
  size      = "s-1vcpu-1gb"
  ssh_keys  = [digitalocean_ssh_key.vault.fingerprint]
}

resource "digitalocean_droplet" "loadbalancer_b" {
  count     = var.loadbalancers
  image     = "fedora-34-x64"
  name      = "loadbalancer-b-${count.index}.meinit.nl"
  region    = "ams3"
  size      = "s-1vcpu-1gb"
  ssh_keys  = [digitalocean_ssh_key.vault.fingerprint]
}

resource "digitalocean_droplet" "loadbalancer" {
  count     = var.loadbalancers
  image     = "fedora-34-x64"
  name      = "loadbalancer-${count.index}.meinit.nl"
  region    = "ams3"
  size      = "s-1vcpu-1gb"
  ssh_keys  = [digitalocean_ssh_key.vault.fingerprint]
}

data "cloudflare_zones" "default" {
  filter {
    name = "meinit.nl"
  }
}

resource "cloudflare_record" "vault_a" {
  count   = var.amount
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "vault-a-${count.index}"
  value   = digitalocean_droplet.vault_a[count.index].ipv4_address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "vault_b" {
  count   = var.amount
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "vault-b-${count.index}"
  value   = digitalocean_droplet.vault_b[count.index].ipv4_address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "loadbalancer_a" {
  count   = var.loadbalancers
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "loadbalancer-a-${count.index}"
  value   = digitalocean_droplet.loadbalancer_a[count.index].ipv4_address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "loadbalancer_b" {
  count   = var.loadbalancers
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "loadbalancer-b-${count.index}"
  value   = digitalocean_droplet.loadbalancer_b[count.index].ipv4_address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "loadbalancer" {
  count   = var.loadbalancers
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "loadbalancer-${count.index}"
  value   = digitalocean_droplet.loadbalancer[count.index].ipv4_address
  type    = "A"
  ttl     = 300
}
