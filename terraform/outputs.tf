output "a" {
  value = cloudflare_record.vault-a.*.hostname
}

output "b" {
  value = cloudflare_record.vault-b.*.hostname
}
