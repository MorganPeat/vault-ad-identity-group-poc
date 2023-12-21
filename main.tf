data "azuread_client_config" "current" {}

resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv"
  options     = { version = "1" } # KISS. It's only a demo.
  description = "KV Version 1 secret engine mount"
}
