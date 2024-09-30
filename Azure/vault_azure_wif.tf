provider "vault" {

}


# Configure Azure Secrets Engine with authentication credentials
resource "vault_azure_secret_backend" "azure" {
  path            = var.azure_secrets_path
  tenant_id       = data.azurerm_client_config.vault_platform_team.tenant_id
  client_id       = azuread_application_registration.example.id
  subscription_id = data.azurerm_subscription.primary.subscription_id

  # This is something like vault.the-tech-tutorial.com:8200/v1/platform-team/identity/oidc/plugins
  identity_token_audience = "${replace(var.vault_addr, "https://", "")}/v1/identity/oidc/plugins"
}

resource "vault_identity_oidc" "server" {
  issuer = var.vault_addr
}

resource "vault_identity_oidc_client" "oidc_client" {
  name          = var.app_name
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_azure_secret_backend_role" "generated_role" {
  backend                     = vault_azure_secret_backend.azure.path
  role                        = "generated_role"
  sign_in_audience            = "AzureADMyOrg"
  tags                        = ["team:engineering","environment:development"]
  ttl                         = 300
  max_ttl                     = 600

  azure_roles {
    role_name = "Reader"
    scope =  "/subscriptions/${var.subscription_id}/resourceGroups/${var.app_name}"
  }
}

# vault read azure/creds/edu-app