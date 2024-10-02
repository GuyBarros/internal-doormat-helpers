provider "vault" {
  # address = var.vault_address
}

resource "vault_identity_oidc" "issuer_url" {
  issuer = var.public_oidc_issuer_url
}

resource "vault_identity_oidc_key" "plugin_wif" {
  name               = "plugin-wif-key"
  rotation_period    = 60 * 60 * 24 * 90 # 90 days
  verification_ttl   = 60 * 60 * 24      # 24 hours
  algorithm          = "RS256"
  allowed_client_ids = [var.azure_audience]
}

data "vault_generic_secret" "azure_secret_mount_details" {
  path    = "sys/mounts/${vault_azure_secret_backend.plugin_wif.path}"
  version = 1
}

resource "time_sleep" "wait_30_seconds_wif" {
  depends_on = [azuread_service_principal.vault_plugin_wif_service_principal]

  create_duration = "30s"
}


resource "vault_azure_secret_backend" "plugin_wif" {
  depends_on = [ azuread_service_principal.vault_plugin_wif_service_principal,time_sleep.wait_30_seconds_wif ]
  path                    = "azure_wif"
  subscription_id         = data.azurerm_subscription.current.subscription_id
  tenant_id               = data.azurerm_subscription.current.tenant_id
  client_id               = azuread_application.vault_plugin_wif_application.client_id
  identity_token_audience = var.azure_audience
  identity_token_ttl      = 60 * 5 # 5 minutes
  identity_token_key      = vault_identity_oidc_key.plugin_wif.id
}

resource "vault_azure_secret_backend_role" "plugin_wif" {
  depends_on = [ azuread_service_principal.vault_plugin_wif_service_principal,time_sleep.wait_30_seconds_wif ,vault_azure_secret_backend.plugin_wif,azuread_application_federated_identity_credential.vault_plugin_wif_federated_credential]
  backend = vault_azure_secret_backend.plugin_wif.path
  role    = "test"
  ttl     = 600
  max_ttl = 900
  azure_roles {
    role_name = "Reader"
    scope     = azurerm_resource_group.example.id
  }
}

resource "azurerm_resource_group" "example" {
  name     = var.app_prefix
  location = "UK West"
}

# vault read azure_wif/creds/test