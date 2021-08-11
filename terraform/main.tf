resource "digitalocean_ssh_key" "vault-demo" {
  name       = "vault demo"
  public_key = file("${path.module}/files/id_rsa.pub")
}

# Create a new Droplet using the SSH key
resource "digitalocean_droplet" "vault-example-a" {
  count     = var.amount
  image     = "fedora-34-x64"
  name      = "vault-a-${count.index}.meinit.nl"
  region    = "ams3"
  size      = "4gb"
  ssh_keys  = [digitalocean_ssh_key.vault-demo.fingerprint]
}

resource "digitalocean_droplet" "vault-example-b" {
  count     = var.amount
  image     = "fedora-34-x64"
  name      = "vault-b-${count.index}.meinit.nl"
  region    = "ams3"
  size      = "4gb"
  ssh_keys  = [digitalocean_ssh_key.vault-demo.fingerprint]
}

data "cloudflare_zones" "default" {
  filter {
    name = "meinit.nl"
  }
}

resource "cloudflare_record" "vault-a" {
  count   = var.amount
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "vault-a-${count.index}"
  value   = digitalocean_droplet.vault-example-a[count.index].ipv4_address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "vault-b" {
  count   = var.amount
  zone_id = data.cloudflare_zones.default.zones[0].id
  name    = "vault-b-${count.index}"
  value   = digitalocean_droplet.vault-example-b[count.index].ipv4_address
  type    = "A"
  ttl     = 300
}
