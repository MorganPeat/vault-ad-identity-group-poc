variable "name" {
  type        = string
  description = "The group name, used to identify the it in each system. Must be a machine-readable 'slug' containing lower-case chars, numbers and hyphens."

  # TODO regex validation of name 'slug'
}

variable "group_members" {
  type        = list(string)
  description = "A list of Azure AD `object_id`s defining which AD Users are members of the AD Group."
}

variable "vault_oidc_backend_accessor" {
  type        = string
  description = "Accessor for the Vault Azure OIDC backend, used to configure the identity group alias."
}