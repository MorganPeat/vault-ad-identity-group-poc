####################################################################
# Configures a group in both Active Directory and Vault
#
# A group of users must exist in many systems. This module shows
# Azure AD and Vault, but a group may also need to be configured
# in (for e.g.) an artifact repository, a VCS, a change management
# system, etc.
# Across all these systems the 'group' has a single lifecycle and
# can be controlled in once place, like this module.
####################################################################

data "azuread_client_config" "current" {}

# Ensures that the list of user IDs is valid.
data "azuread_users" "default" {
  object_ids = var.group_members
}

# In this example, users are added to the group by the caller.
# This enables full self-service and allows membership to be managed using
# terraform.
# In many organisations, AD groups and their membership is managed by an external
# system. In which case, this module could take an existing AD Group as a parameter
# and create all dependent objects, and not manage the AD Group itself.
resource "azuread_group" "default" {
  display_name     = var.name
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = data.azuread_users.default.object_ids
}



# A Vault identity group matches 1-to-1 an Azure AD Group
# `external` means membership of the group (i.e. which Vault logins are members of the group) is 
# mapped to the AD group.
resource "vault_identity_group" "default" {
  name     = var.name
  type     = "external"
  policies = ["default"] # Other permissions can be added later using `vault_identity_group_policies`
}

resource "vault_identity_group_alias" "default" {
  name           = azuread_group.default.object_id
  canonical_id   = vault_identity_group.default.id
  mount_accessor = var.vault_oidc_backend_accessor
}
