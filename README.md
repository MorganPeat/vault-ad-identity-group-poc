# vault-ad-identity-group-poc

PoC looking at how to manage Azure AD groups and members with HashiCorp Vault.

## What gets configured

The terraform code in this repo:

* Configures a Vault auth backend for Microsoft Azure AD
* Creates a new Azure application and uses this to configure Vault's OIDC backend

Information about the AD Groups of any logged-in user is passed to Vault and is used to assign policy documents.

## Application conventions

This repo uses convention to determine what Vault policies are assigned to users, according to the Azure AD Group they are assigned to,
and the role given to that group.

**K/V Secrets** are all stored under a given `kv/` mount and the name (slug) of the application is used to assign policy.  

The policy templates are stored under [./policies](./policies/).

## To test

Retrieve AD user passwords from terraform state:

`terraform state pull | jq '.outputs.azuread_users.value[] | {user_principal_name, password}'`

Navigate to the Vault UI (`vault_address` output).

Log in as different users and test that permissions match those defined in terraform.  Be sure to select `OIDC` as the login method, and make sure 
the vault namespace matches the `vault_namespace` output variable.

View the policies assigned to the logged in user by opening up a CLI window and executing `vault read auth/token/lookup-self`.
