provider "azurerm" {
    subscription_id = var.subscription_id
  features {}
}

# Data source to get the current subscription ID and tenant ID
data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "vault_platform_team" {}

data "azuread_client_config" "current" {}

resource "azuread_application" "vault_platform_team_app" {
  display_name = "guy_test_20240927_v2"
  owners           = [data.azuread_client_config.current.object_id]
 
 required_resource_access {
        resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

        resource_access {
            id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
            type = "Scope"
        }
        resource_access {
            id   = "18a4783c-866b-4cc7-a460-3d5e5662c884" # Application.ReadWrite.OwnedBy
            type = "Role"
        }
 }

}

resource "azuread_application_password" "vault_platform_team_app_password" {
  application_id = azuread_application.vault_platform_team_app.id
}

