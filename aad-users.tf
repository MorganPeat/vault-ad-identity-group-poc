####################################################################
# Configure user accounts in Azure AD
#
# This would typically be automated by an external HR system, with 
# user account created when a user onboards.
####################################################################


locals {
  test_users = {
    app1_lead = "App1 Lead"
    app1_dev  = "App1 Developer"
    app2_lead = "App2 Lead"
    app2_dev  = "App2 Developer"
  }
}

# Assign a random password - these can be read from tf state
# in order to test out Vault access.
resource "random_password" "password" {
  for_each = local.test_users
  length   = 20
}

# Create some test user accounts in Azure AD
resource "azuread_user" "user" {
  for_each = local.test_users

  user_principal_name = "${each.key}@${var.ad_domain}"
  display_name        = each.value
  mail_nickname       = each.key
  password            = random_password.password[each.key].result
}
