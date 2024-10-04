# Azure Storage Account for SFTP

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![Apache V2 License](https://img.shields.io/badge/license-Apache%20V2-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/claranet/storage-sftp/azurerm/)

This Terraform module creates an [Azure Blob Storage with the SFTP feature](https://learn.microsoft.com/en-us/azure/storage/blobs/secure-file-transfer-protocol-support).

It also manages the creation of local SFTP users within the Storage Account. An SSH key pair is automatically generated by Terraform and you have the option of downloading it (enabled by default). SFTP connection command lines and users' passwords are available in the `storage_sftp_users` output of this module.

Storage is created with Premium SKU by default for production ready performances.

<!-- BEGIN_TF_DOCS -->
## Global versioning rule for Claranet Azure modules

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 7.x.x       | 1.3.x             | >= 3.0          |
| >= 6.x.x       | 1.x               | >= 3.0          |
| >= 5.x.x       | 0.15.x            | >= 2.0          |
| >= 4.x.x       | 0.13.x / 0.14.x   | >= 2.0          |
| >= 3.x.x       | 0.12.x            | >= 2.0          |
| >= 2.x.x       | 0.12.x            | < 2.0           |
| <  2.x.x       | 0.11.x            | < 2.0           |

## Contributing

If you want to contribute to this repository, feel free to use our [pre-commit](https://pre-commit.com/) git hook configuration
which will help you automatically update and format some files for you by enforcing our Terraform code module best-practices.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Usage

This module is optimized to work with the [Claranet terraform-wrapper](https://github.com/claranet/terraform-wrapper) tool
which set some terraform variables in the environment needed by this module.
More details about variables set by the `terraform-wrapper` available in the [documentation](https://github.com/claranet/terraform-wrapper#environment).

```hcl
module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "x.x.x"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "x.x.x"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "logs" {
  source  = "claranet/run/azurerm//modules/logs"
  version = "x.x.x"

  location       = module.azure_region.location
  location_short = module.azure_region.location_short
  client_name    = var.client_name
  environment    = var.environment
  stack          = var.stack

  resource_group_name = module.rg.resource_group_name
}

data "http" "my_ip" {
  url = "https://ip.clara.net"
}

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

  resource_group_name = module.rg.resource_group_name

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
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id,
  ]

  extra_tags = {
    foo = "bar"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.114 |
| local | ~> 2.3 |
| tls | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| storage\_account | claranet/storage-account/azurerm | ~> 7.14.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account_local_user.sftp_users](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_local_user) | resource |
| [local_sensitive_file.sftp_users_private_keys](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.sftp_users_public_keys](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [tls_private_key.sftp_users_keys](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_tier | Defines the access tier for `StorageV2` accounts. Valid options are `Hot` and `Cool`, defaults to `Hot`. | `string` | `"Hot"` | no |
| account\_replication\_type | Defines the type of replication to use for this Storage Account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. | `string` | `"ZRS"` | no |
| advanced\_threat\_protection\_enabled | Boolean flag which controls if advanced threat protection is enabled, see [documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-advanced-threat-protection?tabs=azure-portal) for more information. | `bool` | `false` | no |
| allowed\_cidrs | List of CIDR to allow access to that Storage Account. | `list(string)` | `[]` | no |
| client\_name | Client name/account used in naming. | `string` | n/a | yes |
| containers | List of objects to create some Blob containers in this Storage Account. | <pre>list(object({<br/>    name                  = string<br/>    container_access_type = optional(string)<br/>    metadata              = optional(map(string))<br/>  }))</pre> | n/a | yes |
| create\_sftp\_users\_keys | Whether or not key pairs should be created on the filesystem. | `bool` | `true` | no |
| custom\_diagnostic\_settings\_name | Custom name of the diagnostics settings, name will be `default` if not set. | `string` | `"default"` | no |
| custom\_storage\_account\_name | Custom Azure Storage Account name, generated if not set. | `string` | `""` | no |
| default\_firewall\_action | Which default firewalling policy to apply. Valid values are `Allow` or `Deny`. | `string` | `"Deny"` | no |
| default\_tags\_enabled | Option to enable or disable default tags. | `bool` | `true` | no |
| environment | Project environment. | `string` | n/a | yes |
| extra\_tags | Additional tags to associate with the Storage Account. | `map(string)` | `{}` | no |
| https\_traffic\_only\_enabled | Boolean flag which forces HTTPS if enabled. | `bool` | `true` | no |
| identity\_ids | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Storage Account. | `list(string)` | `null` | no |
| identity\_type | Specifies the type of Managed Service Identity that should be configured on this Storage Account. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned` (to enable both). | `string` | `"SystemAssigned"` | no |
| is\_premium | `true` to enable `Premium` tier for this Storage Account. | `bool` | `true` | no |
| location | Azure location. | `string` | n/a | yes |
| location\_short | Short string for Azure location. | `string` | n/a | yes |
| logs\_categories | Log categories to send to destinations. | `list(string)` | `null` | no |
| logs\_destinations\_ids | List of destination resources IDs for logs diagnostic destination.<br/>Can be `Storage Account`, `Log Analytics Workspace` and `Event Hub`. No more than one of each can be set.<br/>If you want to specify an Azure Event Hub to send logs and metrics to, you need to provide a formated string with both the Event Hub Namespace authorization send ID and the Event Hub name (name of the queue to use in the Namespace) separated by the `|` character. | `list(string)` | n/a | yes |
| logs\_metrics\_categories | Metrics categories to send to destinations. | `list(string)` | `null` | no |
| min\_tls\_version | The minimum supported TLS version for the Storage Account. Possible values are `TLS1_0`, `TLS1_1`, and `TLS1_2`. | `string` | `"TLS1_2"` | no |
| name\_prefix | Optional prefix for the generated name. | `string` | `""` | no |
| name\_suffix | Optional suffix for the generated name. | `string` | `""` | no |
| network\_bypass | Specifies whether traffic is bypassed for 'Logging', 'Metrics', 'AzureServices' or 'None'. | `list(string)` | <pre>[<br/>  "Logging",<br/>  "Metrics",<br/>  "AzureServices"<br/>]</pre> | no |
| network\_rules\_enabled | Boolean to enable network rules on the Storage Account, requires `network_bypass`, `allowed_cidrs`, `subnet_ids` or `default_firewall_action` correctly set if enabled. | `bool` | `true` | no |
| nfsv3\_enabled | Is NFSv3 protocol enabled? Changing this forces a new resource to be created. | `bool` | `false` | no |
| private\_link\_access | List of Privatelink objects to allow access from. | <pre>list(object({<br/>    endpoint_resource_id = string<br/>    endpoint_tenant_id   = optional(string, null)<br/>  }))</pre> | `[]` | no |
| public\_nested\_items\_allowed | Allow or disallow nested items within this Storage Account to opt into being public. | `bool` | `false` | no |
| resource\_group\_name | Resource Group name. | `string` | n/a | yes |
| sftp\_users | List of local SFTP user objects. | <pre>list(object({<br/>    name                 = string<br/>    home_directory       = optional(string)<br/>    ssh_key_enabled      = optional(bool, true)<br/>    ssh_password_enabled = optional(bool)<br/>    permissions_scopes = list(object({<br/>      target_container = string<br/>      permissions      = optional(list(string), ["All"])<br/>    }))<br/>    ssh_authorized_keys = optional(list(object({<br/>      key         = string<br/>      description = optional(string)<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| sftp\_users\_keys\_path | The filesystem location in which the key pairs will be created. Default to `~/.ssh/keys`. | `string` | `"~/.ssh/keys"` | no |
| shared\_access\_key\_enabled | Indicates whether the Storage Account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). | `bool` | `true` | no |
| stack | Project stack name. | `string` | n/a | yes |
| static\_website\_config | Static website configuration. | <pre>object({<br/>    index_document     = optional(string)<br/>    error_404_document = optional(string)<br/>  })</pre> | `null` | no |
| storage\_blob\_cors\_rules | Storage Account blob CORS rules. Please refer to the [documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account#cors_rule) for more information. | <pre>list(object({<br/>    allowed_headers    = list(string)<br/>    allowed_methods    = list(string)<br/>    allowed_origins    = list(string)<br/>    exposed_headers    = list(string)<br/>    max_age_in_seconds = number<br/>  }))</pre> | `[]` | no |
| storage\_blob\_data\_protection | Blob Storage data protection parameters. | <pre>object({<br/>    delete_retention_policy_in_days           = optional(number, 0)<br/>    container_delete_retention_policy_in_days = optional(number, 0)<br/>  })</pre> | <pre>{<br/>  "container_delete_retention_policy_in_days": 30,<br/>  "delete_retention_policy_in_days": 30<br/>}</pre> | no |
| subnet\_ids | Subnets to allow access to that Storage Account. | `list(string)` | `[]` | no |
| use\_caf\_naming | Use the Azure CAF naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| storage\_account\_id | Created Storage Account ID. |
| storage\_account\_identity | Created Storage Account identity block. |
| storage\_account\_name | Created Storage Account name. |
| storage\_account\_properties | Created Storage Account properties. |
| storage\_blob\_containers | Created Blob containers in the Storage Account. |
| storage\_sftp\_users | Information about created local SFTP users. |
<!-- END_TF_DOCS -->
