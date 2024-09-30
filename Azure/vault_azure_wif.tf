provider "vault" {

}


# Configure Azure Secrets Engine with authentication credentials
resource "vault_azure_secret_backend" "azure" {
  path            = var.azure_secrets_path
  tenant_id       = data.azurerm_client_config.vault_platform_team.tenant_id
  client_id       = azuread_application.vault_platform_team_app.client_id
  subscription_id = data.azurerm_subscription.primary.subscription_id

  # This is something like vault.the-tech-tutorial.com:8200/v1/platform-team/identity/oidc/plugins
  identity_token_audience = "${replace(var.vault_addr, "https://", "")}/v1/identity/oidc/plugins"
}

resource "vault_identity_oidc" "server" {
  issuer = var.vault_addr
}

resource "vault_identity_oidc_client" "oidc_client" {
  name          = "azure"
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

