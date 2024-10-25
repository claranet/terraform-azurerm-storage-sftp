output "resource" {
  description = "Storage Account resource object."
  value       = module.storage_account
}

output "id" {
  description = "Storage Account ID."
  value       = module.storage_account.id
}

output "name" {
  description = "Storage Account name."
  value       = module.storage_account.name
}

output "identity_principal_id" {
  description = "Storage Account system identity principal ID."
  value       = module.storage_account.identity_principal_id
}

output "module_diagnostics" {
  description = "Diagnostics settings module outputs."
  value       = module.storage_account.module_diagnostics
}

output "blob_containers" {
  description = "Created Blob containers in the Storage Account."
  value       = module.storage_account.resource_blob_containers
}

output "sftp_users" {
  description = "Information about created local SFTP users."
  value       = local.sftp_users_output
  sensitive   = true
}
