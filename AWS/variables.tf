variable "role_name" {
  description = "Name for the IAM role to be used by stacks, unique within your account"
  type        = string
  default     = "tfc-wif-guybarros"

  validation {
    condition     = length(var.role_name) <= 64
    error_message = "IAM role name must be no longer than 64 characters."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9_+=,.@-]+$", var.role_name))
    error_message = "IAM role name can only include alphanumeric characters and _+=,.@- punctuation."
  }
}

variable "organization_id" {
  description = "Terraform Cloud organization ID, of the form org-abcdef"
  type        = string
  default = "org-mBNTjPmxEsB6mfwT"

  validation {
    condition     = startswith(var.organization_id, "org-")
    error_message = "The organization_id value must be a valid Terraform Cloud identifier, starting with \"org-\". You can find this identifier in the organization settings page."
  }
}

variable "allowed_actions" {
  description = "List of IAM actions allowed for this role. For example, [\"s3:*\"]"
  type        = list(string)

  validation {
    condition     = length(var.allowed_actions) > 0
    error_message = "At least one allowed action is required."
  }
  default = ["*"]
}