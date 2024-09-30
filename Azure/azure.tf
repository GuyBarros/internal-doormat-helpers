provider "azurerm" {
    subscription_id = var.subscription_id
  features {}
}

# Data source to get the current subscription ID and tenant ID
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "vault_platform_team" {}

data "azuread_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}
