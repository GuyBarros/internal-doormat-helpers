resource "azurerm_resource_group" "vault_app_rg" {
  name     = var.app_name
  location = "West Europe"
}