# v7.3.0 - 2024-01-05

Added
  * AZ-1323: Add `private_link_access` parameter

# v7.2.0 - 2023-09-08

Breaking
  * AZ-1153: Remove `retention_days` parameters, it must be handled at destination level now. (for reference: [Provider issue](https://github.com/hashicorp/terraform-provider-azurerm/issues/23051))

# v7.1.0 - 2023-04-07

Breaking
  * AZ-1050: Use the `azurerm_storage_account_local_user` resource instead of the AzAPI resource

# v7.0.0 - 2023-03-03

Added
  * AZ-924: Initialize Storage Account SFTP module
