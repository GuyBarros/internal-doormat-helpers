data "vault_namespace" "current" {
}



resource "azuread_application_federated_identity_credential" "federated_credential" {
  application_id        = "/applications/${azuread_application.vault_platform_team_app.client_id}"
  display_name          = "Vault Federated Credential"
  issuer            = "${var.vault_addr}/v1/${var.app_name}/identity/oidc/plugins"
  subject           = "plugin-identity:*:secret:${vault_azure_secret_backend.azure.id}"
  # subject           = "plugin-identity:${data.vault_namespace.current.namespace_id}:secret:${vault_azure_secret_backend.azure.id}"
  audiences         = [replace("${var.vault_addr}/v1/${var.app_name}/identity/oidc/plugins", "https://", "")]
  description           = "test Azure SE mount using WIF"
}