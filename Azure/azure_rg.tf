resource "azurerm_resource_group" "example" {
  name     = var.app_name
  location = "West Europe"
}