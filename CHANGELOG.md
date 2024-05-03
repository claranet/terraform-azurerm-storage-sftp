## 7.4.0 (2024-05-03)


### Features

* change `storage_blob_cors_rule` to a list, allow multiple cors rules b39160a


### Continuous Integration

* **AZ-1391:** enable semantic-release [skip ci] 8340f2e
* **AZ-1391:** update semantic-release config [skip ci] 1ca9074


### Miscellaneous Chores

* **deps:** add renovate.json a8d3f71
* **deps:** enable automerge on renovate 75c393f
* **deps:** update dependency claranet/storage-account/azurerm to ~> 7.11.0 be1e898
* **deps:** update dependency opentofu to v1.7.0 ff9a76b
* **deps:** update dependency tflint to v0.51.0 eef47ab
* **deps:** update dependency trivy to v0.50.2 d64024d
* **deps:** update dependency trivy to v0.50.4 f5c004f
* **deps:** update renovate.json 0aed33d
* **deps:** update terraform claranet/storage-account/azurerm to ~> 7.10.0 52ef302
* **deps:** update terraform claranet/storage-account/azurerm to ~> 7.12.0 996c73d
* **pre-commit:** update commitlint hook 086a75d
* **release:** remove legacy `VERSION` file 96a9e6c

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
