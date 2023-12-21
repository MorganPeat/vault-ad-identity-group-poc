variable "vault_address" {
  type        = string
  description = "Public URL of the HCP Vault Cluster"
}

variable "vault_namespace" {
  type        = string
  description = "Vault namespace used for this PoC"
}

variable "azure_tenant_id" {
  type        = string
  description = "Tenant ID of Azure AD"
}

variable "ad_domain" {
  type        = string
  description = "Active Directory domain in which users are created"
}
