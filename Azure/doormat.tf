terraform {
  required_providers {
    doormat = {
      source  = "doormat.hashicorp.services/hashicorp-security/doormat"
    }
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [azuread_application.vault_plugin_wif_application]

  create_duration = "30s"
}


resource "doormat_azure_app_secrets_access_for_vault" "app_reg_privilege" {
  depends_on = [time_sleep.wait_30_seconds]
    app_object_id = azuread_application.vault_plugin_wif_application.object_id
    tenant_id     = data.azurerm_client_config.current.tenant_id

}
