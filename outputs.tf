output "storage_account_properties" {
  description = "Created Storage Account properties."
  value       = module.storage_account.storage_account_properties
  sensitive   = true
}

output "storage_account_id" {
  description = "Created Storage Account ID."
  value       = module.storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Created Storage Account name."
  value       = module.storage_account.storage_account_name
}

output "storage_account_identity" {
  description = "Created Storage Account identity block."
  value       = module.storage_account.storage_account_identity
}

output "storage_account_network_rules" {
  description = "Network rules of the associated Storage Account."
  value       = module.storage_account.storage_account_network_rules
}

output "storage_blob_containers" {
  description = "Created Blob containers in the Storage Account."
  value       = module.storage_account.storage_blob_containers
}

output "storage_sftp_users" {
  description = "Information about created local SFTP users."
  value       = local.sftp_users_output
  sensitive   = true
}
