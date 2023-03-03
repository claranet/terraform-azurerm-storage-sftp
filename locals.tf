locals {
  sftp_users = {
    for user in var.sftp_users : user.name => user
  }

  sftp_users_permissions_map = {
    "All"    = "rwldc"
    "Read"   = "r"
    "Write"  = "w"
    "List"   = "l"
    "Delete" = "d"
    "Create" = "c"
  }

  sftp_users_output = {
    for key, value in azapi_resource.sftp_users : key => {
      id                         = jsondecode(value.output).id
      auto_generated_private_key = tls_private_key.sftp_users_keys[key].private_key_pem
      auto_generated_public_key  = tls_private_key.sftp_users_keys[key].public_key_openssh

      # Will land on the home directory
      sftp_default_connection_cmd = format(
        "sftp -i %s %s.%s@%s.blob.core.windows.net",
        try(local_sensitive_file.sftp_users_private_keys[key].filename, "<privateKeyPath>"),
        module.storage_account.storage_account_name,
        key,
        module.storage_account.storage_account_name,
      )

      # Direct access to each container
      sftp_containers_connection_cmd = {
        for scope in jsondecode(value.output).properties.permissionScopes : scope.resourceName => format(
          "sftp -i %s %s.%s.%s@%s.blob.core.windows.net",
          try(local_sensitive_file.sftp_users_private_keys[key].filename, "<privateKeyPath>"),
          module.storage_account.storage_account_name,
          scope.resourceName,
          key,
          module.storage_account.storage_account_name,
        )
      }
    }
  }
}
