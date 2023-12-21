output "azuread_users" {
  description = "Test users and their passwords"
  sensitive   = true
  value       = azuread_user.user
}

output "vault_address" {
  description = "Public URL of the HCP Vault Cluster"
  value       = var.vault_address
}

output "vault_namespace" {
  description = "Vault namespace used for this PoC"
  value       = var.vault_namespace
}
