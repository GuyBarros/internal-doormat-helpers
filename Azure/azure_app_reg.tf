resource "azuread_application_registration" "example" {
  display_name = "guy_wif_test"
}
resource "azuread_application_password" "vault_app_reg_password" {
  application_id = azuread_application_registration.example.id
}

/*
resource "azuread_application_owner" "doormat_user" {
  application_id  = azuread_application_registration.example.id
  owner_object_id = data.azuread_client_config.current.object_id
}
*/

resource "azuread_application_federated_identity_credential" "example" {
  application_id = azuread_application_registration.example.id
  display_name   = "vault-wif"
  #issuer         = "${var.vault_addr}/v1/${var.app_name}/identity/oidc/plugins"
  issuer         = "${var.vault_addr}/v1/identity/oidc/plugins"
  subject        = "plugin-identity:*:secret:${vault_azure_secret_backend.azure.id}"
  # subject           = "plugin-identity:${data.vault_namespace.current.namespace_id}:secret:${vault_azure_secret_backend.azure.id}"
  audiences   = [replace("${var.vault_addr}/v1/${var.app_name}/identity/oidc/plugins", "https://", "")]
  description = "test Azure SE mount using WIF"
}



resource "azuread_application_api_access" "example_msgraph" {
  application_id = azuread_application_registration.example.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  role_ids = [
    data.azuread_service_principal.msgraph.app_role_ids["User.Read.All"],
    data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.OwnedBy"],
  ]

#   scope_ids = [
#     data.azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.ReadWrite"],
#   ]
}
