####################################################################
# Configures a test 'application 1' in Azure AD and Vault.
#
# Creates an AD Group and associated Vault identity group. Links
# the AD Group members to Vault identities, so that users will be
# granted group permissions when they log in to vault.
####################################################################


# Add some AD Groups for the application.
# Some of this may be done by an external IdP but this example
# shows how groups and their membership can be made self-service
# to the application team.
module "application_1_leads" {
  source = "./modules/group"

  name                        = "application-1-leads"
  vault_oidc_backend_accessor = vault_jwt_auth_backend.azure_oidc.accessor
  group_members               = [azuread_user.user["app1_lead"].object_id, ]
}

module "application_1_developers" {
  source = "./modules/group"

  name                        = "application-1-developers"
  vault_oidc_backend_accessor = vault_jwt_auth_backend.azure_oidc.accessor
  group_members               = [azuread_user.user["app1_dev"].object_id, ]
}





# It's not possible (yet) to use a single template policy document. A template policy
# can only expand out to a single policy, not multiple.
# So we do our own template expansion here, and map a single template file out
# to identical-looking policy documents.
#
# The idea is to have role-based policies, where permissions for a given role (e.g. 
# secret reader, secret writer) are coded once but applied many times (once per 'scope',
# where scope is 'application' here).
resource "vault_policy" "application_1_readers" {
  name   = "application-1-reader"
  policy = templatefile("./policies/reader.tftpl", { application = "application-1" })
}

resource "vault_policy" "application_1_writers" {
  name   = "application-1-writer"
  policy = templatefile("./policies/writer.tftpl", { application = "application-1" })
}


# RBAC is assigned here just for Vault, but it would be straightforward to push
# this into a module and assign 'standard' permissions to other systems too.

resource "vault_identity_group_policies" "application_1_leads_write" {
  group_id  = module.application_1_leads.vault_identity_group_id
  exclusive = false
  policies  = [vault_policy.application_1_writers.name]
}

resource "vault_identity_group_policies" "application_1_devs_read" {
  group_id  = module.application_1_developers.vault_identity_group_id
  exclusive = false
  policies  = [vault_policy.application_1_readers.name]
}

# Allow application 2 leads to read secrets for application 1.
resource "vault_identity_group_policies" "application_1_app_2_leads_read" {
  group_id  = module.application_2_leads.vault_identity_group_id
  exclusive = false
  policies  = [vault_policy.application_1_readers.name]
}
