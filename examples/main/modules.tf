# When using RSA algorithm, do not forget to add `-o PubkeyAcceptedKeyTypes=+ssh-rsa` in your SFTP connection command line
# e.g. `sftp -o PubkeyAcceptedKeyTypes=+ssh-rsa -i <privateKeyPath> <storageAccountName>.<sftpLocalUserName>@<storageAccountName>.blob.core.windows.net`
resource "tls_private_key" "bar_example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "storage_sftp" {
  source  = "claranet/storage-sftp/azurerm"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.name

  name_suffix = "sftp"

  account_replication_type = "LRS"

  allowed_cidrs = [chomp(data.http.my_ip.response_body)]

  containers = [
    {
      name = "foo"
    },
    {
      name = "bar"
    },
  ]

  nfsv3_enabled = true # SFTP can be used alongside the NFSv3 feature for Blob Storage

  sftp_users = [
    {
      name                 = "foo"
      home_directory       = "foo/example" # `example` is a subdirectory under `foo` container
      ssh_password_enabled = true
      permissions_scopes = [
        {
          target_container = "foo"
        },
        {
          target_container = "bar"
          permissions      = ["Read", "Write", "List"]
        },
      ]
    },
    {
      name = "bar"
      permissions_scopes = [
        {
          target_container = "bar"
        },
        {
          target_container = "foo"
          permissions      = ["List", "Create"]
        },
      ]
      ssh_authorized_keys = [{
        key         = tls_private_key.bar_example.public_key_openssh
        description = "Example"
      }]
    }
  ]

  logs_destinations_ids = [
    # module.logs.logs_storage_account_id,
    # module.logs.log_analytics_workspace_id,
  ]

  extra_tags = {
    foo = "bar"
  }
}
