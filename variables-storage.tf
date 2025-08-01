# Storage Account parameters

variable "is_premium" {
  description = "`true` to enable `Premium` tier for this Storage Account."
  type        = bool
  default     = true
  nullable    = false
}

variable "access_tier" {
  description = "Defines the access tier for `StorageV2` accounts. Valid options are `Hot` and `Cool`, defaults to `Hot`."
  type        = string
  default     = "Hot"
  nullable    = false
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this Storage Account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`."
  type        = string
  default     = "ZRS"
  nullable    = false
}

variable "https_traffic_only_enabled" {
  description = "Boolean flag which forces HTTPS if enabled."
  type        = bool
  default     = true
  nullable    = false
}

variable "public_nested_items_allowed" {
  description = "Allow or disallow nested items within this Storage Account to opt into being public."
  type        = bool
  default     = false
  nullable    = false
}

variable "shared_access_key_enabled" {
  description = "Indicates whether the Storage Account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD)."
  type        = bool
  default     = false
  nullable    = false
}

variable "min_tls_version" {
  description = "The minimum supported TLS version for the Storage Account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. "
  type        = string
  default     = "TLS1_2"
  nullable    = false
}

variable "rbac_storage_contributor_role_principal_ids" {
  description = "The principal IDs of the users, groups, and service principals to assign the `Storage Account Contributor` role to."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "rbac_storage_blob_role_principal_ids" {
  description = "The principal IDs of the users, groups, and service principals to assign the `Storage Blob Data *` different roles to if Blob containers are created."
  type = object({
    owners       = optional(list(string), [])
    contributors = optional(list(string), [])
    readers      = optional(list(string), [])
  })
  default  = {}
  nullable = false
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
  nullable    = false
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

variable "blob_data_protection" {
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

variable "blob_cors_rules" {
  description = "Storage Account blob CORS rules. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information."
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default  = []
  nullable = false
}

variable "allowed_copy_scope" {
  description = "Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are `AAD` or `PrivateLink`."
  type        = string
  default     = null
  validation {
    condition     = var.allowed_copy_scope == null || try(contains(["AAD", "PrivateLink"], var.allowed_copy_scope), false)
    error_message = "Allowed values for allowed_copy_scope are `AAD` or `PrivateLink`."
  }
}

# Threat protection

variable "advanced_threat_protection_enabled" {
  description = "Boolean flag which controls if advanced threat protection is enabled, see [documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-advanced-threat-protection?tabs=azure-portal) for more information."
  type        = bool
  default     = false
  nullable    = false
}

# Infrastructure encryption

variable "infrastructure_encryption_enabled" {
  description = "Whether Infrastructure Encryption is enabled, see [documentation](https://learn.microsoft.com/en-us/azure/storage/common/infrastructure-encryption-enable?tabs=portal) for more information."
  type        = bool
  default     = false
  nullable    = false
}

# Storage firewall

variable "network_rules_enabled" {
  description = "Boolean to enable network rules on the Storage Account, requires `network_bypass`, `allowed_cidrs`, `subnet_ids` or `default_firewall_action` correctly set if enabled."
  type        = bool
  default     = true
  nullable    = false
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
  nullable    = false
}

variable "subnet_ids" {
  description = "Subnets to allow access to that Storage Account."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "default_firewall_action" {
  description = "Which default firewalling policy to apply. Valid values are `Allow` or `Deny`."
  type        = string
  default     = "Deny"
  nullable    = false
}

variable "private_link_access" {
  description = "List of Privatelink objects to allow access from."
  type = list(object({
    endpoint_resource_id = string
    endpoint_tenant_id   = optional(string, null)
  }))
  default  = []
  nullable = false
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
    name                 = string
    home_directory       = optional(string)
    ssh_key_enabled      = optional(bool, true)
    ssh_password_enabled = optional(bool)
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
  nullable    = false
}

variable "sftp_users_keys_path" {
  description = "The filesystem location in which the key pairs will be created. Default to `~/.ssh/keys`."
  type        = string
  default     = "~/.ssh/keys"
}
