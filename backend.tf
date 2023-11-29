terraform {
  cloud {
    organization = "mp-demo-org"

    workspaces {
      name = "vault-ad-identity-group-poc"
    }
  }
}