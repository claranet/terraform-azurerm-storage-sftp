# Common

variable "location_short" {
  description = "Short string for Azure location."
  type        = string
}

variable "location" {
  description = "Azure location."
  type        = string
}

variable "client_name" {
  description = "Client name/account used in naming."
  type        = string
}

variable "environment" {
  description = "Project environment."
  type        = string
}

variable "stack" {
  description = "Project stack name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name."
  type        = string
}

# Storage Account parameters

variable "is_premium" {
  description = "`true` to enable `Premium` tier for this Storage Account."
  type        = bool
  default     = true
}

variable "access_tier" {
  description = "Defines the access tier for `StorageV2` accounts. Valid options are `Hot` and `Cool`, defaults to `Hot`."
  type        = string
  default     = "Hot"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this Storage Account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`."
  type        = string
  default     = "ZRS"
}

variable "https_traffic_only_enabled" {
  description = "Boolean flag which forces HTTPS if enabled."
  type        = bool
  default     = true
}

variable "public_nested_items_allowed" {
  description = "Allow or disallow nested items within this Storage Account to opt into being public."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the Storage Account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD)."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the Storage Account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. "
  type        = string
  default     = "TLS1_2"
}

variable "static_website_config" {
  description = "Static website configuration."
  type = object({
    index_document     = optional(string)
    error_404_document = optional(string)
  })
  default = null
}

variable "nfsv3_enabled" {
  description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

# Data creation / protection

variable "containers" {
  description = "List of objects to create some Blob containers in this Storage Account."
  type = list(object({
    name                  = string
    container_access_type = optional(string)
    metadata              = optional(map(string))
  }))
}

variable "storage_blob_data_protection" {
  description = "Blob Storage data protection parameters."
  type = object({
    delete_retention_policy_in_days           = optional(number, 0)
    container_delete_retention_policy_in_days = optional(number, 0)
  })
  default = {
    delete_retention_policy_in_days           = 30
    container_delete_retention_policy_in_days = 30
  }
}

variable "storage_blob_cors_rule" {
  description = "Blob Storage CORS rule. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information."
  type = object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  })
  default = null
}

# Threat protection

variable "advanced_threat_protection_enabled" {
  description = "Boolean flag which controls if advanced threat protection is enabled, see [documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-advanced-threat-protection?tabs=azure-portal) for more information."
  type        = bool
  default     = false
}

# Storage firewall

variable "network_rules_enabled" {
  description = "Boolean to enable network rules on the Storage Account, requires `network_bypass`, `allowed_cidrs`, `subnet_ids` or `default_firewall_action` correctly set if enabled."
  type        = bool
  default     = true
}

variable "network_bypass" {
  description = "Specifies whether traffic is bypassed for 'Logging', 'Metrics', 'AzureServices' or 'None'."
  type        = list(string)
  default     = ["Logging", "Metrics", "AzureServices"]
}

variable "allowed_cidrs" {
  description = "List of CIDR to allow access to that Storage Account."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Subnets to allow access to that Storage Account."
  type        = list(string)
  default     = []
}

variable "default_firewall_action" {
  description = "Which default firewalling policy to apply. Valid values are `Allow` or `Deny`."
  type        = string
  default     = "Deny"
}

# Identity

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both)."
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account."
  type        = list(string)
  default     = null
}

# SFTP users

variable "sftp_users" {
  description = "List of local SFTP user objects."
  type = list(object({
    name           = string
    home_directory = optional(string)
    permissions_scopes = list(object({
      target_container = string
      permissions      = optional(list(string), ["All"])
    }))
    ssh_authorized_keys = optional(list(object({
      key         = string
      description = optional(string)
    })), [])
  }))
  validation {
    condition     = length(var.sftp_users) <= 1000
    error_message = "You can have a maximum of 1000 local users for a storage account."
  }
  validation {
    condition = alltrue([
      for user in var.sftp_users : length(user.permissions_scopes) <= 100
    ])
    error_message = "You can grant each local user access to a maximum of 100 containers."
  }
  validation {
    condition = alltrue([
      for user in var.sftp_users : length(user.ssh_authorized_keys) < 10
    ])
    error_message = "Maximum of 10 public keys per local user (one key is automatically generated by Terraform)."
  }
}

variable "create_sftp_users_keys" {
  description = "Whether or not key pairs should be created on the filesystem."
  type        = bool
  default     = true
}

variable "sftp_users_keys_path" {
  description = "The filesystem location in which the key pairs will be created. Default to `~/.ssh/keys`."
  type        = string
  default     = "~/.ssh/keys"
}
