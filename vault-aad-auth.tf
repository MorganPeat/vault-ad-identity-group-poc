#
# Configures Vault authentication for Azure AD
#
# OIDC is used to authenticate AAD users with Vault.
# See:
# - https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/azuread
# - https://developer.hashicorp.com/vault/tutorials/auth-methods/oidc-auth-azure
# - https://www.hashicorp.com/blog/integrating-azure-ad-identity-hashicorp-vault-part-1-application-auth-oidc
# - https://www.hashicorp.com/blog/integrating-azure-ad-identity-with-hashicorp-vault-part-2-vault-oidc-auth-method

locals {
  redirect_uris = [
    "${var.vault_address}/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}

resource "azuread_application" "hcp_vault" {
  display_name = "hcp-vault"
  owners       = [data.azuread_client_config.current.object_id]

  web {
    redirect_uris = local.redirect_uris
  }

  # Grants permission to read AD Groups and their users
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["GroupMember.Read.All"]
      type = "Scope" # Delegated
    }
  }

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allows the app to list groups, read basic group properties and read membership of all groups the signed-in user has access to."
      admin_consent_display_name = "Read group memberships"
      id                         = data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["GroupMember.Read.All"]
      type                       = "Admin"
      enabled                    = true
      value                      = "administer"
    }
  }

  # Ensure AD group membership information is included in the JWT returned by Azure
  group_membership_claims = ["SecurityGroup"]

  optional_claims {
    access_token {
      name = "groups"
    }

    id_token {
      name = "groups"
    }

    saml2_token {
      name = "groups"
    }
  }
}


resource "azuread_service_principal" "hcp_vault" {
  application_id = azuread_application.hcp_vault.application_id
  owners         = [data.azuread_client_config.current.object_id]
}


resource "azuread_application_password" "vault" {
  display_name          = "Vault"
  application_object_id = azuread_application.hcp_vault.object_id
}


resource "vault_jwt_auth_backend" "azure_oidc" {
  description        = "Azure AD"
  oidc_discovery_url = "https://login.microsoftonline.com/${var.azure_tenant_id}/v2.0"
  path               = "oidc"
  type               = "oidc"
  oidc_client_id     = azuread_application.hcp_vault.application_id
  oidc_client_secret = azuread_application_password.vault.value
  default_role       = "azure"
}

resource "vault_jwt_auth_backend_role" "azure_role" {
  role_name             = "azure"
  backend               = vault_jwt_auth_backend.azure_oidc.path
  user_claim            = "sub"
  groups_claim          = "groups"
  role_type             = "oidc"
  oidc_scopes           = ["https://graph.microsoft.com/.default"]
  allowed_redirect_uris = local.redirect_uris
  token_policies        = ["default", ]
}