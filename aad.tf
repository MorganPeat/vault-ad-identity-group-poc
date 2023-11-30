locals {
  ad_domain = "morganmpeatco.onmicrosoft.com"

  user_names = {
    bart  = "Bart Simpson"
    lisa  = "Lisa Simpson"
    homer = "Homer Simpson"
    marge = "Marge Simpson"
  }
}

resource "random_password" "password" {
  for_each = local.user_names

  length = 20
}

resource "azuread_user" "user" {
  for_each = local.user_names

  user_principal_name = "${each.key}@${local.ad_domain}"
  display_name        = each.value
  mail_nickname       = each.key
  password            = random_password.password[each.key].result
}

resource "azuread_group" "test_group" {
  display_name     = "test-group"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    azuread_user.user["bart"].object_id,
    azuread_user.user["lisa"].object_id
  ]
}


resource "vault_identity_group" "test_group" {
  name     = "test-group"
  type     = "external"
  policies = ["vault-ad-identity-group-poc"]

  metadata = {
    version = "1"
  }
}


resource "vault_identity_group_alias" "test_group_azuread" {
  name           = azuread_group.test_group.object_id
  mount_accessor = vault_jwt_auth_backend.azure_oidc.accessor
  canonical_id   = vault_identity_group.test_group.id
}