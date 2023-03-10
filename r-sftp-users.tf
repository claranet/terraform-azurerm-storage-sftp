# https://learn.microsoft.com/en-us/azure/storage/blobs/secure-file-transfer-protocol-support#supported-algorithms
resource "tls_private_key" "sftp_users_keys" {
  for_each = local.sftp_users

  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "azapi_resource" "sftp_users" {
  for_each = local.sftp_users

  type = "Microsoft.Storage/storageAccounts/localUsers@2022-09-01"

  name = each.key

  parent_id = module.storage_account.storage_account_id

  body = jsonencode({
    properties = {
      # Azure can generate the private key only through the Azure portal
      hasSshKey = true

      # The first container in the `permissions_scopes` list will always be the default home directory
      homeDirectory = coalesce(each.value.home_directory, each.value.permissions_scopes[0].target_container)

      # https://learn.microsoft.com/en-us/azure/storage/blobs/secure-file-transfer-protocol-support#container-permissions
      permissionScopes = [
        for scope in each.value.permissions_scopes : {
          service      = "blob"
          resourceName = scope.target_container
          permissions = contains(scope.permissions, "All") ? local.sftp_users_permissions_map["All"] : join("", [
            for permission in distinct(scope.permissions) : local.sftp_users_permissions_map[permission]
          ])
        }
      ]

      sshAuthorizedKeys = concat(
        [{
          key         = tls_private_key.sftp_users_keys[each.key].public_key_openssh
          description = "Automatically generated by Terraform"
        }],
        each.value.ssh_authorized_keys,
      )
    }
  })

  response_export_values = [
    "id",
    "properties.homeDirectory",
    "properties.permissionScopes",
  ]

  lifecycle {
    precondition {
      condition = alltrue([
        for scope in each.value.permissions_scopes : contains(keys(module.storage_account.storage_blob_containers), scope.target_container)
      ])
      error_message = format("At least one target container does not exist for user %s.", each.key)
    }
    precondition {
      condition = alltrue(flatten([
        for scope in each.value.permissions_scopes : [
          for permission in scope.permissions : [
            contains(keys(local.sftp_users_permissions_map), permission)
          ]
        ]
      ]))
      error_message = format("One or more permissions are wrong for user %s. Allowed values in the list are: %s.", each.key, join(", ", [
        for permission in keys(local.sftp_users_permissions_map) : "'${permission}'"
      ]))
    }
    # Required because otherwise Terraform will apply successfully but the SFTP connection will fail when using the SFTP default connection command line
    postcondition {
      condition     = contains(jsondecode(self.output).properties.permissionScopes[*].resourceName, split("/", jsondecode(self.output).properties.homeDirectory)[0])
      error_message = format("The home directory of user %s does not refer to any container in its permissions scopes.", reverse(split("/", self.id))[0])
    }
  }
}

resource "local_sensitive_file" "sftp_users_private_keys" {
  for_each = var.create_sftp_users_keys ? tls_private_key.sftp_users_keys : {}

  content         = each.value.private_key_pem
  filename        = pathexpand(format("%s/%s_%s.pem", var.sftp_users_keys_path, module.storage_account.storage_account_name, each.key))
  file_permission = "0600"
}

resource "local_sensitive_file" "sftp_users_public_keys" {
  for_each = var.create_sftp_users_keys ? tls_private_key.sftp_users_keys : {}

  content         = each.value.public_key_openssh
  filename        = pathexpand(format("%s/%s_%s.pub", var.sftp_users_keys_path, module.storage_account.storage_account_name, each.key))
  file_permission = "0644"
}
