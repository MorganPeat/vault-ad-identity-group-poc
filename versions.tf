terraform {

  required_version = "~> 1.6.0" # Matches the TFE workspace - must be changed in sync

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.15.0"
    }
  }
}