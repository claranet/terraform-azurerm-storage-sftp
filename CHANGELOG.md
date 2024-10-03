## 7.4.4 (2024-10-03)

### Documentation

* update README badge to use OpenTofu registry 272eee4
* update README with `terraform-docs` v0.19.0 1ec7fc5

### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.8.2 def8489
* **deps:** update dependency terraform-docs to v0.19.0 07d35cd
* **deps:** update dependency trivy to v0.55.0 e044d01
* **deps:** update dependency trivy to v0.55.1 a2e0651
* **deps:** update dependency trivy to v0.55.2 f6275b4
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.18.0 51a60a2
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.1 399842c
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.2 253fc20
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.3 303b0d6
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.95.0 58e31f0
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.96.0 9ec275b
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.96.1 d9d0369

## 7.4.3 (2024-08-30)

### Bug Fixes

* bump `storage-account` to latest version 5ba142b

### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.8.1 0aac923
* **deps:** update dependency tflint to v0.53.0 533b60c
* **deps:** update pre-commit hook alessandrojcm/commitlint-pre-commit-hook to v9.17.0 5f8f6d9
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.2 15d248f
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.94.0 b221955

## 7.4.2 (2024-08-05)


### Bug Fixes

* **AZ-1446:** remove `storage_account_network_rules` output 89bcc58


### Miscellaneous Chores

* **deps:** update dependency opentofu to v1.7.3 3556b02
* **deps:** update dependency pre-commit to v3.8.0 6e61abf
* **deps:** update dependency tflint to v0.51.2 2a5dd50
* **deps:** update dependency tflint to v0.52.0 8069179
* **deps:** update dependency trivy to v0.53.0 1675a94
* **deps:** update dependency trivy to v0.54.1 734950c
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.0 53700e4
* **deps:** update pre-commit hook antonbabenko/pre-commit-terraform to v1.92.1 94242e3
* **deps:** update tools 3811b7c

## 7.4.1 (2024-06-14)


### ⚠ BREAKING CHANGES

* bump minimum AzureRM provider version

### Code Refactoring

* module storage requires provider `v3.102+` 9b5e981


### Miscellaneous Chores

* **deps:** update dependency claranet/storage-account/azurerm to ~> 7.13.0 e73797d
* **deps:** update dependency opentofu to v1.7.1 5d147cf
* **deps:** update dependency opentofu to v1.7.2 b38dd79
* **deps:** update dependency pre-commit to v3.7.1 d379e97
* **deps:** update dependency terraform-docs to v0.18.0 6b77402
* **deps:** update dependency tflint to v0.51.1 42850a7
* **deps:** update dependency trivy to v0.51.0 044a3d1
* **deps:** update dependency trivy to v0.51.1 4686249
* **deps:** update dependency trivy to v0.51.2 e9dd021
* **deps:** update dependency trivy to v0.51.4 c4e2b11
* **deps:** update dependency trivy to v0.52.0 ba69a0f
* **deps:** update dependency trivy to v0.52.1 796bcee
* **deps:** update dependency trivy to v0.52.2 b6d36da

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
