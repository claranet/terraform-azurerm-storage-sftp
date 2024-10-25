locals {
  sftp_users = {
    for user in var.sftp_users : user.name => user
  }

  sftp_users_with_ssh_key_enabled = {
    for key, value in local.sftp_users : key => value if value.ssh_key_enabled
  }

  sftp_users_permissions = [
    "All",
    "Read",
    "Write",
    "List",
    "Delete",
    "Create",
  ]

  sftp_users_output = {
    for key, value in azurerm_storage_account_local_user.main : key => {
      id       = value.id
      name     = value.name
      password = value.password

      auto_generated_private_key = try(tls_private_key.main[key].private_key_pem, "")
      auto_generated_public_key  = try(tls_private_key.main[key].public_key_openssh, "")

      # Will land on the home directory
      sftp_default_connection_cmd = format(
        "sftp -o PubkeyAcceptedKeyTypes=+ssh-rsa -i %s %s.%s@%s",
        try(local_sensitive_file.sftp_users_private_keys[key].filename, "<privateKeyPath>"),
        module.storage_account.name, key,
        module.storage_account.resource.primary_blob_host,
      )

      # Direct access to each container
      sftp_containers_connection_cmd = {
        for scope in value.permission_scope : scope.resource_name => format(
          "sftp -o PubkeyAcceptedKeyTypes=+ssh-rsa -i %s %s.%s.%s@%s",
          try(local_sensitive_file.sftp_users_private_keys[key].filename, "<privateKeyPath>"),
          module.storage_account.name, scope.resource_name, key,
          module.storage_account.resource.primary_blob_host,
        )
      }
    }
  }
}
