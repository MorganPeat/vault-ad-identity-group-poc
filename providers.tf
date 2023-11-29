# Azure authN is by workload identity using env variables
# stored in this workspace
# See https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret#environment-variables
provider "azuread" {}

provider "random" {}

# Enables access to secrets stored in vault.
# Vault authN is by workload identity using env variables
# stored in this workspace.
# See https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/vault-configuration.
provider "vault" {}
