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

data "azuread_client_config" "current" {}


resource "azuread_group" "test_group" {
  display_name     = "test-group"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [
    azuread_user.user["bart"].object_id,
    azuread_user.user["lisa"].object_id
  ]
}
