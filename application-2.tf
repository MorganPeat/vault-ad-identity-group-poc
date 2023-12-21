####################################################################
# Configures a test 'application 2' in Azure AD and Vault.
#
# See `application-1.tf` for description.
####################################################################


module "application_2_leads" {
  source = "./modules/group"

  name                        = "application-2-leads"
  vault_oidc_backend_accessor = vault_jwt_auth_backend.azure_oidc.accessor
  group_members               = [azuread_user.user["app2_lead"].object_id, ]
}

module "application_2_developers" {
  source = "./modules/group"

  name                        = "application-2-developers"
  vault_oidc_backend_accessor = vault_jwt_auth_backend.azure_oidc.accessor
  group_members               = [azuread_user.user["app2_dev"].object_id, ]
}


resource "vault_policy" "application_2_writers" {
  name   = "application-2-writer"
  policy = templatefile("./policies/writer.tftpl", { application = "application-2" })
}

resource "vault_identity_group_policies" "application_2_leads_write" {
  group_id  = module.application_2_leads.vault_identity_group_id
  exclusive = false
  policies  = [vault_policy.application_2_writers.name]
}
