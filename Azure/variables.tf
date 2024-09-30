variable "subscription_id" {
    description = "the Azure subscription ID for the Azure Provider"
}
variable "app_name" {
  description   = "Will be used for azure app and namespace naming"
  default       = "vault-platform-all-in-one"
  type         = string
}

variable "vault_addr" {
  description = "The Vault Address"
  type        = string
  sensitive   = true
}

variable "azure_secrets_path" {
  description = "Path where Azure Secrets Engine is enabled (default is 'azure/')"
  type        = string
  default     = "azure"
}
