output "vault_a" {
  value = cloudflare_record.vault_a.*.hostname
}

output "vault_b" {
  value = cloudflare_record.vault_b.*.hostname
}

output "loadbalancer_a" {
  value = cloudflare_record.loadbalancer_a.*.hostname
}

output "loadbalancer_b" {
  value = cloudflare_record.loadbalancer_b.*.hostname
}

output "loadbalancer" {
  value = cloudflare_record.loadbalancer.*.hostname
}
